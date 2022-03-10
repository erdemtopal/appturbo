class Message < ApplicationRecord
	validates :body, presence: true
	broadcasts_to ->(message) { :inbox_list }, inserts_by: :prepend, target: 'messages'

	after_commit :send_html_counter, on: [ :create, :destroy ]
	  def send_html_counter
	    broadcast_update_to('inbox_list', target: 'sayi_revize', html: "#{Message.count}")
	    # broadcast_update_to('inbox_list', target: 'inbox_count', html: Inbox.count)
	  end


end
