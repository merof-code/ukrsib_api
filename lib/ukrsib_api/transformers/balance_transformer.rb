# frozen_string_literal: true

module UkrsibAPI
  module Transformers
    # balance field name mappings
    class BalanceTransformer < UkrsibAPI::BaseTransformer
      # Define the mapping for keys that need renaming
      KEY_MAPPING = {
        "acc" => :account,
        "atp" => :account_type,
        "currency" => :currency,
        "flmn" => :location,
        "state" => :state,
        "balanceIn" => :balance_in,
        "balanceInEq" => :balance_in_uah,
        "balanceOut" => :balance_out,
        "balanceOutEq" => :balance_out_uah,
        "turnoverDebt" => :turnover_debt,
        "turnoverDebtEq" => :turnover_debt_uah,
        "turnoverCred" => :turnover_cred,
        "turnoverCredEq" => :turnover_cred_uah,
        "bgfIBrnm" => :counterparty_branch,
        "brnm" => :account_branch,
        "dpd" => :last_operation_date_time,
        "nameACC" => :account_name,
        "date_open_acc_reg" => :open_account_reg_date_time,
        "date_open_acc_sys" => :open_account_sys_date_time,
        "date_close_acc" => :close_account_date_time,
        "is_final_bal" => :final_balance
      }.freeze

      build_pipeline(KEY_MAPPING)
    end
  end
end
