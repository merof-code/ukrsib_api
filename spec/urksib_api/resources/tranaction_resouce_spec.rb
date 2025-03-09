# frozen_string_literal: true

require "spec_helper"

RSpec.describe UkrsibAPI::Resources::TransactionResource do
  it "retrieves transaction info, transforms fields correctly, and exposes money methods" do
    stub = stub_request(
      "api/statements/transactions?limit=20&startDate=02-03-2025",
      response: stub_response(fixture: "transactions")
    )

    client = UkrsibAPI::Client.new(api_token: "fake", adapter: :test, stubs: stub)
    transactions = client.transactions.list(start_date: Date.new(2025, 3, 2))

    # Assuming the fixture contains one transaction.
    expect(transactions.count).to eq 2
    tx = transactions.first
    expect(tx).to be_a(UkrsibAPI::Models::Transaction)

    # Check transformed fields.
    expect(tx.recipient_code).to eq("00000000")
    expect(tx.recipient_bank_code).to         eq("00000000")
    expect(tx.recipient_account).to           eq("UA2630000000000000000000000000")
    expect(tx.recipient_name).to              eq("Couterparty name")
    expect(tx.recipient_bank_name).to         eq('АТ КБ "ПРИВАТБАНК"')
    expect(tx.recipient_bank_city).to         eq("Дніпро")
    expect(tx.counterparty_code).to           eq("00000000")
    expect(tx.counterparty_bank_code).to      eq("00000000")
    expect(tx.counterparty_account).to        eq("UA2030000000000000000000000000")
    expect(tx.counterparty_name).to           eq("USD валютна позицiя (Compass, ISS1)")
    expect(tx.counterparty_bank_name).to      eq('АТ КБ "ПРИВАТБАНК"')
    expect(tx.counterparty_bank_city).to      eq("Дніпро")
    expect(tx.currency).to                    eq("UAH")
    expect(tx.real).to                        eq("r")
    expect(tx.status).to                      eq("r")
    expect(tx.document_type).to               eq("m")
    expect(tx.document_number).to             eq("0dddddd0d0d")

    # Date fields: formatting for easier comparison.
    expect(tx.client_date.strftime("%d.%m.%Y")).to eq("02.03.2025")
    expect(tx.valuation_date.strftime("%d.%m.%Y")).to eq("03.03.2025")
    expect(tx.valuation_date_time.strftime("%d.%m.%Y %H:%M:%S")).to eq("03.03.2025 03:31:00")

    expect(tx.reason).to                     eq("**** **** 02.03.2025 11:48:20 ")
    expect(tx.amount).to                     eq(BigDecimal("100.00"))
    expect(tx.amount_uah).to                 eq(BigDecimal("100.00"))
    expect(tx.reference).to                  eq("0dddddd0d0d")
    expect(tx.reference_number).to           eq("1")
    # The valuation_time field is declared as JSON::Time.
    expect(tx.valuation_time.strftime("%H:%M")).to eq("03:31")
    expect(tx.id).to                         eq("00000000")
    expect(tx.transaction_type).to           eq("D")
    expect(tx.service_reference).to          eq("00000000")
    expect(tx.technical_id).to               eq("00000000_online")

    # Verify the money helper methods.
    money_amount     = Money.from_amount(tx.amount, tx.currency)
    money_amount_uah = Money.from_amount(tx.amount_uah, "UAH")

    expect(tx.amount_money).to      eq(money_amount)
    expect(tx.amount_uah_money).to  eq(money_amount_uah)
  end
end
