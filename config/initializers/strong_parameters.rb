# Strong parameters
# -----------------
#
# This is part of rails4 by default. Using the rails3 gem for now which needs
# this activation code.
#
# We apply strong parameters to all models to begin with... let's see if we
# remove it for some later on.
#

ActiveRecord::Base.send(:include, ActiveModel::ForbiddenAttributesProtection)

