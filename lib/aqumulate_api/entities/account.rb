module AqumulateAPI
  class Account < Entity

    ATTR_MAP = {
        id: 'AcctId',
        login_account_id: 'FILoginAcctId',
        added_by: 'AccountAddedBy',
        financial_institution_id: 'FIId',
        account_type: 'AccountType',
        account_type_extended: 'ExtendedAccountType',
        nick_name: 'NickNameAtFI',
        update_error_code: 'UpdateErrorCode',
        retirement_status: 'RetirementStatus',
        instrument: 'Instrument',
        ownership: 'AccountOwnership',
        adv_access: 'AdvAccess',
        tracking_code: 'TrackingCode',
        last_update_status_code: 'LastUpdateStatusCode',
        last_update_status_msg: 'LastUpdateStatusMsg',
        last_update_status_msg_fi: 'LastUpdateStatusMessageAtFI',
        last_update_attempt: 'LastUpdateAttempt',
        last_update: 'LastSuccessfulUpdate'
    }

    SOURCE_ASSOCIATIONS = [
        { key: 'AccountBalances', class: AccountBalance, attr: :account_balances },
        { key: 'Positions', class: Position, attr: :positions }
    ]

    attr_accessor :id, :login_account_id, :added_by, :financial_institution_id, :account_type, :account_type_extended,
                  :nick_name, :update_error_code, :retirement_status, :instrument, :ownership, :adv_access,
                  :tracking_code, :last_update_status_code, :last_update_status_msg, :last_update_status_msg_fi,
                  :last_update_attempt, :last_update, :account_balances, :positions

    def self.find(advisor, fi_id = nil)
      body = { 'SessionId' => advisor.session_id }
      body['FIId'] = fi_id unless fi_id.nil?

      response = AggAccount.advisor_agg_get_account_for_fi(body)
      return [] unless response.has_key?('Accounts')

      response['Accounts'].map { |source| from_source(source) }
    end

    def account_balances
      @account_balances ||= []
    end

    def positions
      @positions ||= []
    end

    def financial_institution
      @financial_institution ||= FinancialInstitution.find(financial_institution_id)
    end

  end
end