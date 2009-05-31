SRC:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include $(or $(shell make-common),$(error make-common is not on your PATH!))

include $(SRC)/module.mk
