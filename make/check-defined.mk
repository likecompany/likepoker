check_defined = \
    $(strip $(foreach 1,$1, \
        $(call check_defined_detail,$1,$(strip $(value 2)))))
check_defined_detail = \
    $(if $(value $1),, \
      $(error Undefined variable: $1$(if $2, ($2))))
