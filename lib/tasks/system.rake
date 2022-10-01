namespace :system do

  desc 'Send Error Digest to Admins'
  task :send_error_digest, [:minutes] => :environment do |_t, args|
    minimum_timeframe = 5
    minutes = ( [ args[:minutes].to_i, minimum_timeframe ].max rescue 60 )

    events = SystemEvent.notifiable.recent(minutes).order(created_at: :desc)
    notify_users = User.admins.includes(:user_profile).
      select{|user| user.user_profile.notification_admin_errors? }

    unless events.present?
      puts "*** ! No events of interest in the past #{minutes} minutes"
      exit(0)
    end

    unless notify_users.present?
      puts "*** ! No users to notify!"
      exit(1)
    end

    puts "*** Sending email notification of errors the past #{minutes} minutes"
    puts " - Recipients: #{notify_users.map(&:email).join(', ') }"
    SystemMailer.error_digest(events:, notify_users: ).deliver
  end
end
