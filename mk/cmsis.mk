SVN_REV = 27441

ARM_CMSIS_ASSETS = \
	mbed_preprocessor.h \
	mbed_assert.h

ARM_CMSIS_ASSETS := $(addprefix $(CMSIS)/util/, $(ARM_CMSIS_ASSETS))

$(CMSIS): $(CMSIS)/arm $(CMSIS)/TARGET_STM $(ARM_CMSIS_ASSETS)
	@mkdir -p $@

$(CMSIS)/arm:
	svn export -r$(SVN_REV) -q --force https://github.com/ARMmbed/mbed-os/trunk/cmsis/ $(CMSIS)/arm

$(CMSIS)/TARGET_STM:
	svn export -r$(SVN_REV) -q --force https://github.com/ARMmbed/mbed-os/trunk/targets/TARGET_STM/ $(CMSIS)/TARGET_STM

$(ARM_CMSIS_ASSETS):
	wget -q https://raw.github.com/ARMmbed/mbed-os/master/platform/$(notdir $@) -P $(CMSIS)/util
	touch $@
