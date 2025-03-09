# frozen_string_literal: true

require "spec_helper"

RSpec.describe UkrsibAPI::Resources::BalanceResource do
  it "retrieves account info, transforms fields correctly, and exposes money methods" do
    stub = stub_request(
      "api/statements/balance?limit=20&startDate=02-03-2025",
      response: stub_response(fixture: "balances")
    )

    client = UkrsibAPI::Client.new(api_token: "fake", adapter: :test, stubs: stub)
    balances = client.balances.list(Date.new(2025, 3, 2))

    # We expect two records from the fixture
    expect(balances.count).to eq 2

    balance = balances.first
    expect(balance).to be_a(UkrsibAPI::Models::Balance)

    # Check transformed fields.
    expect(balance.account).to eq("UA5430000000000000000000000000")
    expect(balance.currency).to eq("EUR")
    expect(balance.counterparty_branch).to eq(" ")
    expect(balance.account_branch).to eq("DND0")
    expect(balance.account_name).to eq("??????????  ??????")
    expect(balance.state).to eq("a")
    expect(balance.account_type).to eq("T")
    expect(balance.location).to eq("DR")
    expect(balance.final_balance).to eq(false)

    # Monetary values are defined as Coercible::Decimal,
    # so we compare against BigDecimal representations.
    expect(balance.balance_in).to eq(BigDecimal("100.00"))
    expect(balance.balance_in_uah).to eq(BigDecimal("100.00"))
    expect(balance.balance_out).to eq(BigDecimal("100.00"))
    expect(balance.balance_out_uah).to eq(BigDecimal("100.00"))
    expect(balance.turnover_debt).to eq(BigDecimal("100.00"))
    expect(balance.turnover_debt_uah).to eq(BigDecimal("100.00"))
    expect(balance.turnover_cred).to eq(BigDecimal("100.00"))
    expect(balance.turnover_cred_uah).to eq(BigDecimal("100.00"))

    # DateTime fields - format the dates as strings for easy comparison.
    expect(balance.last_operation_date_time.strftime("%d.%m.%Y %H:%M:%S")).to eq("03.03.2025 00:00:00")
    expect(balance.open_account_reg_date_time.strftime("%d.%m.%Y %H:%M:%S")).to eq("26.01.2023 17:03:31")
    expect(balance.open_account_sys_date_time.strftime("%d.%m.%Y %H:%M:%S")).to eq("26.01.2023 00:00:00")
    expect(balance.close_account_date_time.strftime("%d.%m.%Y %H:%M:%S")).to eq("01.01.1900 00:00:00")

    # Check the money fields.
    # For fields not ending in _uah, the model's currency should be used.
    money_balance_in     = Money.from_amount(balance.balance_in, balance.currency)
    money_balance_out    = Money.from_amount(balance.balance_out, balance.currency)
    money_turnover_debt  = Money.from_amount(balance.turnover_debt, balance.currency)
    money_turnover_cred  = Money.from_amount(balance.turnover_cred, balance.currency)

    # For _uah fields, UAH should be the currency.
    money_balance_in_uah    = Money.from_amount(balance.balance_in_uah, "UAH")
    money_balance_out_uah   = Money.from_amount(balance.balance_out_uah, "UAH")
    money_turnover_debt_uah = Money.from_amount(balance.turnover_debt_uah, "UAH")
    money_turnover_cred_uah = Money.from_amount(balance.turnover_cred_uah, "UAH")

    expect(balance.balance_in_money).to eq(money_balance_in)
    expect(balance.balance_out_money).to eq(money_balance_out)
    expect(balance.turnover_debt_money).to eq(money_turnover_debt)
    expect(balance.turnover_cred_money).to eq(money_turnover_cred)

    expect(balance.balance_in_uah_money).to eq(money_balance_in_uah)
    expect(balance.balance_out_uah_money).to eq(money_balance_out_uah)
    expect(balance.turnover_debt_uah_money).to eq(money_turnover_debt_uah)
    expect(balance.turnover_cred_uah_money).to eq(money_turnover_cred_uah)
  end
end
