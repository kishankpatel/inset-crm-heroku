module BootstrapFlashHelper
ALERT_TYPES = [:danger, :info, :success, :warning, :bosuccess, :bodanger, :bowarning, :error]

	def bootstrap_flash
		flash_messages = []
		flash.each do |type, message|
			# Skip empty messages, e.g. for devise messages set to nothing in a locale file.
			next if message.blank?
				type = :success if type == :notice || type == :bosuccess
				type = :error if type == :alert || type == :bodanger
				next unless ALERT_TYPES.include?(type)
					Array(message).each do |msg|
					text = content_tag(:div,
					content_tag(:div,
					content_tag(:button, raw("&times;"), :class => "toast-close-button", "role" => "button", "type" => "button") +
					content_tag(:div, msg.html_safe, :style => "display:inline-block;vertical-align:middle;")), :class => "close-toast animated fadeInDown toast-#{type}", :style => "display: block;")
					flash_messages << text if msg
					p "======================="
					p text
				end
		end
		puts "------------------- flash messages ------------------"
		p flash_messages.join("\n").html_safe
	end
end