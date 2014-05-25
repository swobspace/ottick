shared_context "basic variables" do
  let(:wsdl) { File.expand_path(File.join(__FILE__, '../../fixtures/otrs/GenericTicketConnector.wsdl')) }
  let(:endpoint) { ENV['ENDPOINT'] }
  let(:otrs_user) { ENV['OTRS_USER'] }
  let(:otrs_passwd) { ENV['OTRS_PASSWD'] }
  let(:ticket_get_id) { ENV['TICKET_GET_ID'] }
  let(:basic_auth) {
    if ENV['HTTP_AUTH_USER']
      {basic_auth: [ENV['HTTP_AUTH_USER'], ENV['HTTP_AUTH_PASSWD']]}
    else
      {}
    end
  }
end
