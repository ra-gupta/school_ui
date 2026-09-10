module Api
  module V1
    class UsersController < BaseController
      # What the app needs to draw itself: who you are, what you may do, and
      # which modules this school switched on.
      def self.profile(user)
        school = user.school
        {
          id: user.id, name: user.name, email: user.email_address, phone: user.phone,
          kind: user.kind, permissions: user.permissions,
          school: school && { id: school.id, name: school.name, code: school.code,
                              currency: school.currency, timezone: school.timezone,
                              primary_color: school.primary_color, logo: nil },
          modules: SchoolModule.all.select { school&.module_enabled?(it.key) }
                               .map { { key: it.key, name: it.name, icon: it.icon, group: it.group } },
          student_ids: user.student ? [user.student.id] : user.guardian&.students&.ids.to_a,
          staff_id: user.staff&.id
        }
      end

      def me = render(json: self.class.profile(current_user))
    end
  end
end
