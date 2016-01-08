require "ruby-sendhub/version"
require 'httparty'
require 'json'

class SendHub
	include HTTParty

	attr_accessor :api_key, :number

	headers  "Content-Type" => "application/json"
	
	def initialize(api_key = nil, number = nil)
		@number = number
		@api_key = api_key
	end

	def method_missing(method, hsh = {})
		meth = method.to_s.split("_")
		if meth.first == "put" || meth.first == "delete"
			if meth.last == "messages"
				api_url = base_url + meth.last + "/" + hsh[:id].to_s + credentials
				hsh.delete(:id)
			else
				api_url = base_url + meth.last + "/" + hsh[:id].to_s + credentials
			end
		elsif meth.first == "get" && (meth.last == "messages" || !hsh[:id].nil?)
			api_url = base_url + meth.last + "/" + hsh[:id].to_s + credentials
		else
			api_url = base_url + meth.last + credentials
		end
		ret = send_request(meth.first, api_url, :body => hsh.to_json)
		ret.nil? && meth.first == "delete" ? "Aaaand it's gone" : ret
	end

	def get_groups_contacts(hsh = {})
		send_request("get", group_contacts_url(hsh), :body => hsh.to_json)
	end

	def post_groups_contacts(hsh = {})
		send_request("post", group_contacts_url(hsh), :body => hsh.to_json)
	end

	def get_contacts(hsh = {}, contact_id=false)
		if hsh.count > 0 and hsh[:contact_id].blank?
			api_url = base_url + "contacts" + credentials + "&" + hsh.to_query
		elsif hsh.count > 0 and hsh[:contact_id].blank?
			api_url = base_url + "contacts/" + hsh[:contact_id].to_s + credentials + "&" + hsh.to_query
		else
			api_url = base_url + "contacts" + credentials
		end
		send_request("get", api_url, :body => {})
	end

	def get_threads(hsh = {})
		thread_id = hsh.delete(:id)
		api_url = base_url + "threads/" + thread_id.to_s + credentials + "&" + hsh.to_query
		send_request("get", api_url, :body => hsh.to_json)
	end

	def get_inbox(hsh = {})
		api_url = base_url + "inbox" + credentials + "&" + hsh.to_query
		send_request("get", api_url, :body => hsh.to_json)
	end

	private

		def group_contacts_url(hsh)
			base_url + "groups/" + hsh[:id].to_s + "/contacts" + credentials
		end

		def send_request(request_type, url, json)
			self.class.send(request_type, url, json).parsed_response
		end

		def base_url
			"https://api.sendhub.com/v1/"
		end

		def credentials
			"/?username=#{number}&api_key=#{api_key}"
		end

end
