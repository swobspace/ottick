require 'spec_helper'
require_relative './support/variables.rb'

# -- run this example with rspec -t modify
describe 'TicketCreate' do
  describe "with valid settings", modify: true do
    include_context "basic variables"

    before(:each) do
      @ticket = Ottick::Ticket.new({ 
		  wsdl: wsdl, endpoint: endpoint, otrs_user: otrs_user, 
		  otrs_passwd: otrs_passwd }.merge(basic_auth)
		)
    end

    it "ticket_create returns some content" do
      subject  = "Testticket from webservice"
      text     = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

      response = @ticket.ticket_create(subject, text)
      expect(response.body).to include(:ticket_create_response)
      ts = response.body[:ticket_create_response]
      expect(ts).to include(:ticket_id)
      expect(ts).to include(:article_id)
      expect(ts).to include(:ticket_number)

      response = @ticket.ticket_get("TicketID" => ts[:ticket_id])
      expect(response.body[:ticket_get_response][:ticket]).to include(:title)
      expect(response.body[:ticket_get_response][:ticket][:title]).to eq(subject)
    end
    
  end

  describe "with invalid settings" do
    before(:each) do
      @ticket = Ottick::Ticket.new()
    end

    it "ticket.create should not raise errors" do
      expect{ @ticket.create("subject", "body") }.not_to raise_error
      expect( @ticket.create("subject", "body") ).to be_nil
    end

    it "ticket.create should contain errors" do
      @ticket.create("subject", "body")
      expect(@ticket.errors.any?).to be_truthy
      expect( @ticket.errors.join(',') ).to match(/Exception occurred:/)
    end
  end
end
