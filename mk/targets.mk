PREFIX = k8s

include $(TOP)/mk/docker-targets.mk

define BUILD
.PHONY: $(PREFIX)-$(NAME)-build
EXAMPLE_NAMES+=${NAME}
$(PREFIX)-$(NAME)-build: $(addsuffix -build,$(addprefix ${CONTAINER_BUILD_PREFIX}-$(NAME)-,$(CONTAINERS)))
endef
$(eval $(BUILD))

define SAVE
.PHONY: $(PREFIX)-$(NAME)-save
$(PREFIX)-$(NAME)-save: $(addsuffix -save,$(addprefix ${CONTAINER_BUILD_PREFIX}-$(NAME)-,$(CONTAINERS))) $(addsuffix -save,$(addprefix ${CONTAINER_BUILD_PREFIX}-,$(AUX_CONTAINERS)))
endef
$(eval $(SAVE))

define LOAD_IMAGES
.PHONY: $(PREFIX)-$(NAME)-load-images
$(PREFIX)-$(NAME)-load-images:  $(addsuffix -load-images,$(addprefix $(CLUSTER_RULES_PREFIX)-$(NAME)-,$(CONTAINERS))) $(addsuffix -load-images,$(addprefix $(CLUSTER_RULES_PREFIX)-,$(AUX_CONTAINERS)))
endef
$(eval $(LOAD_IMAGES))

define DEPLOY
.PHONY: $(PREFIX)-$(NAME)-deploy
$(PREFIX)-$(NAME)-deploy: $(PREFIX)-$(NAME)-delete $(PREFIX)-$(NAME)-load-images $(addsuffix -deploy,$(addprefix $(PREFIX)-$(NAME)-,$(PODS)))

.PHONY: $(PREFIX)-$(NAME)-%-deploy
$(PREFIX)-$(NAME)-%-deploy:
	@sed "s;\(image:[ \t]*networkservicemesh/[^:]*\).*;\1$${COMMIT/$${COMMIT}/:$${COMMIT}};" examples/$(NAME)/$(PREFIX)/\$$*.yaml | kubectl apply -f -
endef
$(eval $(DEPLOY))

define DELETE
.PHONY: $(PREFIX)-$(NAME)-delete
$(PREFIX)-$(NAME)-delete:
	@echo "Deleting examples/$(NAME)/$(PREFIX)/"
	@kubectl delete -R -f examples/$(NAME)/$(PREFIX)/ > /dev/null 2>&1 || echo "$* does not exist and thus cannot be deleted"
endef
$(eval $(DELETE))

define RUN_CHECK
.PHONY: $(PREFIX)-$(NAME)-check
$(PREFIX)-$(NAME)-check:
	@cd examples/$(NAME) && $(CHECK)
endef
$(eval $(RUN_CHECK))