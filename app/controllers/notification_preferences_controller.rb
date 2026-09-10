# Everyone manages their own alerts. There is no permission here on purpose —
# these are the signed-in person's own settings, not school data.
class NotificationPreferencesController < ApplicationController
  def show
    @user = current_user
  end

  def update
    current_user.update!(
      notification_channels: Array(params[:notification_channels]).compact_blank & Notifications::Channel.available,
      muted_events: SchoolEvent.keys - Array(params[:subscribed_events]).compact_blank
    )
    redirect_to notification_preferences_path, notice: "Alert settings saved."
  end
end
