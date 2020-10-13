module V1
  class ClientApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    formatter :json, Grape::Formatter::Rabl
    #prefix :api

    helpers do
      def get_company_id
        @current_user.current_company || @current_user.first_company_id
      end
    end


    resource :clients do
      before {current_user}

      desc 'Fetch all industries'
      get :industries do
        INDUSTRY_LIST
      end

      desc 'Fetch all currencies'
      get :currencies do
        Currency.all
      end

      desc 'Fetch all countries'
      get :countries do
        COUNTRY_LIST
      end

      desc 'Fetch  single client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: String
      end
      get ':id' do
        client = Client.find(params[:id])
        {client: client, amount_billed: client.amount_billed.to_s+" "+client.currency_code, payments_received: client.payments_received.to_s+" "+client.currency_code,
         outstanding_amount: client.outstanding_amount.to_s+" "+client.currency_code, client_invoices: Invoice.joins(:client).where("client_id = ?", params[:id])}
      end

      desc 'Return clients',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get :rabl => 'clients/client.rabl' do
        criteria = {
            status: params[:status] || 'unarchived',
            user: @current_user,
            current_company: get_company_id,
            company_id: get_company_id,
            sort_direction: 'desc',
            sort_column: 'contact_name',
            per: params[:per]
        }

        @clients = Client.get_clients(criteria)
      end

      desc 'Create Client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :client, type: Hash do
          optional :organization_name, type: String
          requires :email, type: String
          requires :first_name, type: String
          requires :last_name, type: String
          optional :home_phone, type: String
          optional :mobile_number, type: String
          optional :send_invoice_by, type: String
          optional :country, type: String
          optional :address_street1, type: String
          optional :address_street2, type: String
          optional :city, type: String
          optional :province_state, type: String
          optional :postal_zip_code, type: String
          optional :industry, type: String
          optional :company_size, type: String
          optional :business_phone, type: String
          optional :fax, type: String
          optional :internal_notes, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :available_credit, type: Integer
        end
      end

      post do
        Services::Apis::ClientApiService.create(params.merge(controller: 'clients'))
      end

      desc 'Update Client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :client, type: Hash do
          optional :organization_name, type: String
          optional :email, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :home_phone, type: String
          optional :mobile_number, type: String
          optional :send_invoice_by, type: String
          optional :country, type: String
          optional :address_street1, type: String
          optional :address_street2, type: String
          optional :city, type: String
          optional :province_state, type: String
          optional :postal_zip_code, type: String
          optional :industry, type: String
          optional :company_size, type: String
          optional :business_phone, type: String
          optional :fax, type: String
          optional :internal_notes, type: String
          optional :archive_number, type: String
          optional :archived_at, type: DateTime
          optional :deleted_at, type: DateTime
          optional :available_credit, type: Integer
        end
      end

      patch ':id' do
        Services::Apis::ClientApiService.update(params)
      end

      desc 'Delete client',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :id, type: Integer, desc: 'Delete Client'
      end
      delete ':id' do
        Services::Apis::ClientApiService.destroy(params[:id])
      end

    end
  end
end
