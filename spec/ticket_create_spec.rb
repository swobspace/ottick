require 'spec_helper'
require_relative './support/variables.rb'

# -- run this example with rspec -t modify
describe 'TicketCreate', modify: true do
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

    response = @ticket.create(subject, text)
    response.body.should include(:ticket_create_response)
    ts = response.body[:ticket_create_response]
    ts.should include(:ticket_id)
    ts.should include(:article_id)
    ts.should include(:ticket_number)

    response = @ticket.get("TicketID" => ts[:ticket_id])
    response.body[:ticket_get_response][:ticket].should include(:title)
    response.body[:ticket_get_response][:ticket][:title].should == subject
    
  end
  
end
