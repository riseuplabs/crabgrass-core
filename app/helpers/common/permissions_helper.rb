#
# PermissionsHelper
#
# Some very basic syntax sugar for pundit
#
module Common
  module PermissionsHelper
    def may_index?(klass)
      policy(klass).index?
    end

    def may_show?(record)
      policy(record).show?
    end

    def may_twinkle?(record)
      policy(record).twinkle?
    end

    def may_update?(record)
      policy(record).update?
    end

    def may_create?(klass)
      policy(klass).create?
    end

    def may_destroy?(record)
      policy(record).destroy?
    end

    def may_admin?(record)
      policy(record).admin?
    end
  end
end
