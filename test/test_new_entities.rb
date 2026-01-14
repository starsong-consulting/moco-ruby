#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "test_helper"
require "webmock/test_unit"

class TestNewEntities < Test::Unit::TestCase
  def setup
    WebMock.disable_net_connect!
    @client = MOCO::Client.new(subdomain: "example", api_key: "test-api-key")
  end

  def teardown
    WebMock.reset!
  end

  # Test dynamic collection access for all new entities
  def test_dynamic_collection_access_new_entities
    # Standalone entities
    assert_respond_to @client, :contacts
    assert_respond_to @client, :offers
    assert_respond_to @client, :purchases
    assert_respond_to @client, :receipts
    assert_respond_to @client, :units
    assert_respond_to @client, :comments
    assert_respond_to @client, :tags
    assert_respond_to @client, :taggings
    assert_respond_to @client, :deal_categories
    assert_respond_to @client, :project_groups

    # Account-level entities
    assert_respond_to @client, :catalog_services
    assert_respond_to @client, :custom_properties
    assert_respond_to @client, :expense_templates
    assert_respond_to @client, :fixed_costs
    assert_respond_to @client, :hourly_rates
    assert_respond_to @client, :internal_hourly_rates
    assert_respond_to @client, :task_templates
    assert_respond_to @client, :user_roles

    # VAT codes
    assert_respond_to @client, :vat_code_sales
    assert_respond_to @client, :vat_code_purchases

    # User sub-resources
    assert_respond_to @client, :employments
    assert_respond_to @client, :work_time_adjustments

    # Purchase sub-resources
    assert_respond_to @client, :purchase_categories
    assert_respond_to @client, :purchase_drafts
  end

  # Test profile singleton
  def test_profile
    stub_request(:get, "https://example.mocoapp.com/api/v1/profile")
      .to_return(
        status: 200,
        body: {
          id: 123,
          firstname: "Test",
          lastname: "User",
          email: "test@example.com"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    profile = @client.profile
    assert_instance_of MOCO::Profile, profile
    assert_equal "Test", profile.firstname
    assert_equal "User", profile.lastname
    assert_equal "Test User", profile.to_s
  end

  # Test reports proxy
  def test_reports_absences
    stub_request(:get, "https://example.mocoapp.com/api/v1/report/absences")
      .with(query: { year: 2024 })
      .to_return(
        status: 200,
        body: [{ user_id: 1, vacation_days: 25 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @client.reports.absences(year: 2024)
    assert_kind_of Array, result
    assert_equal 1, result.first["user_id"]
  end

  def test_reports_utilization
    stub_request(:get, "https://example.mocoapp.com/api/v1/report/utilization")
      .with(query: { from: "2024-01-01", to: "2024-01-31" })
      .to_return(
        status: 200,
        body: [{ user_id: 1, hours: 160 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @client.reports.utilization(from: "2024-01-01", to: "2024-01-31")
    assert_kind_of Array, result
  end

  # Test Contact entity
  def test_get_contacts
    stub_request(:get, "https://example.mocoapp.com/api/v1/contacts/people")
      .to_return(
        status: 200,
        body: [
          { id: 1, firstname: "John", lastname: "Doe", gender: "M" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    contacts = @client.contacts.all
    assert_equal 1, contacts.size
    assert_instance_of MOCO::Contact, contacts.first
    assert_equal "John Doe", contacts.first.to_s
  end

  def test_create_contact
    stub_request(:post, "https://example.mocoapp.com/api/v1/contacts/people")
      .to_return(
        status: 201,
        body: { id: 1, firstname: "Jane", lastname: "Smith", gender: "F" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    contact = @client.contacts.create(firstname: "Jane", lastname: "Smith", gender: "F")
    assert_equal 1, contact.id
    assert_equal "Jane", contact.firstname
  end

  # Test Offer entity
  def test_get_offers
    stub_request(:get, "https://example.mocoapp.com/api/v1/offers")
      .to_return(
        status: 200,
        body: [
          { id: 1, identifier: "O-001", title: "Test Offer" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    offers = @client.offers.all
    assert_equal 1, offers.size
    assert_instance_of MOCO::Offer, offers.first
    assert_equal "O-001 - Test Offer", offers.first.to_s
  end

  def test_offer_update_status
    stub_request(:get, "https://example.mocoapp.com/api/v1/offers/1")
      .to_return(
        status: 200,
        body: { id: 1, identifier: "O-001", title: "Test Offer" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    stub_request(:put, "https://example.mocoapp.com/api/v1/offers/1/update_status")
      .with(body: { status: "accepted" }.to_json)
      .to_return(status: 200, body: {}.to_json)

    offer = @client.offers.find(1)
    offer.update_status("accepted")
  end

  # Test Purchase entity
  def test_get_purchases
    stub_request(:get, "https://example.mocoapp.com/api/v1/purchases")
      .to_return(
        status: 200,
        body: [
          { id: 1, title: "Office Supplies", date: "2024-01-15" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    purchases = @client.purchases.all
    assert_equal 1, purchases.size
    assert_instance_of MOCO::Purchase, purchases.first
    assert_equal "Office Supplies (2024-01-15)", purchases.first.to_s
  end

  # Test Receipt entity
  def test_get_receipts
    stub_request(:get, "https://example.mocoapp.com/api/v1/receipts")
      .to_return(
        status: 200,
        body: [
          { id: 1, title: "Lunch Receipt", date: "2024-01-15" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    receipts = @client.receipts.all
    assert_equal 1, receipts.size
    assert_instance_of MOCO::Receipt, receipts.first
  end

  # Test Unit entity
  def test_get_units
    stub_request(:get, "https://example.mocoapp.com/api/v1/units")
      .to_return(
        status: 200,
        body: [
          { id: 1, name: "Development Team" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    units = @client.units.all
    assert_equal 1, units.size
    assert_instance_of MOCO::Unit, units.first
    assert_equal "Development Team", units.first.to_s
  end

  # Test Comment entity
  def test_get_comments
    stub_request(:get, "https://example.mocoapp.com/api/v1/comments")
      .to_return(
        status: 200,
        body: [
          { id: 1, text: "This is a test comment" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    comments = @client.comments.all
    assert_equal 1, comments.size
    assert_instance_of MOCO::Comment, comments.first
  end

  # Test Tag entity
  def test_get_tags
    stub_request(:get, "https://example.mocoapp.com/api/v1/tags")
      .to_return(
        status: 200,
        body: [
          { id: 1, name: "Important" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    tags = @client.tags.all
    assert_equal 1, tags.size
    assert_instance_of MOCO::Tag, tags.first
    assert_equal "Important", tags.first.to_s
  end

  # Test DealCategory entity
  def test_get_deal_categories
    stub_request(:get, "https://example.mocoapp.com/api/v1/deal_categories")
      .to_return(
        status: 200,
        body: [
          { id: 1, name: "New Business" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    categories = @client.deal_categories.all
    assert_equal 1, categories.size
    assert_instance_of MOCO::DealCategory, categories.first
  end

  # Test ProjectGroup entity
  def test_get_project_groups
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/groups")
      .to_return(
        status: 200,
        body: [
          { id: 1, name: "Client Projects" }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    groups = @client.project_groups.all
    assert_equal 1, groups.size
    assert_instance_of MOCO::ProjectGroup, groups.first
  end

  # Test account-level entities
  def test_get_catalog_services
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/catalog_services")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Consulting" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    services = @client.catalog_services.all
    assert_equal 1, services.size
    assert_instance_of MOCO::CatalogService, services.first
  end

  def test_get_custom_properties
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/custom_properties")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Department" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    properties = @client.custom_properties.all
    assert_equal 1, properties.size
    assert_instance_of MOCO::CustomProperty, properties.first
  end

  def test_get_hourly_rates
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/hourly_rates")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Standard", rate: 150 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    rates = @client.hourly_rates.all
    assert_equal 1, rates.size
    assert_instance_of MOCO::HourlyRate, rates.first
    assert_equal "Standard - 150", rates.first.to_s
  end

  def test_get_task_templates
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/task_templates")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Standard Tasks" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    templates = @client.task_templates.all
    assert_equal 1, templates.size
    assert_instance_of MOCO::TaskTemplate, templates.first
  end

  # Test User roles
  def test_get_user_roles
    stub_request(:get, "https://example.mocoapp.com/api/v1/users/roles")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Admin", is_admin: true }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    roles = @client.user_roles.all
    assert_equal 1, roles.size
    assert_instance_of MOCO::UserRole, roles.first
  end

  # Test VAT codes
  def test_get_vat_code_sales
    stub_request(:get, "https://example.mocoapp.com/api/v1/vat_code_sales")
      .to_return(
        status: 200,
        body: [{ id: 1, code: "VAT19", name: "19% VAT" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    vat_codes = @client.vat_code_sales.all
    assert_equal 1, vat_codes.size
    assert_instance_of MOCO::VatCodeSale, vat_codes.first
    assert_equal "VAT19 - 19% VAT", vat_codes.first.to_s
  end

  def test_get_vat_code_purchases
    stub_request(:get, "https://example.mocoapp.com/api/v1/vat_code_purchases")
      .to_return(
        status: 200,
        body: [{ id: 1, code: "VATP19", name: "19% Purchase VAT" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    vat_codes = @client.vat_code_purchases.all
    assert_equal 1, vat_codes.size
    assert_instance_of MOCO::VatCodePurchase, vat_codes.first
  end

  # Test User employment entity
  def test_get_employments
    stub_request(:get, "https://example.mocoapp.com/api/v1/users/employments")
      .to_return(
        status: 200,
        body: [{ id: 1, from: "2020-01-01", to: nil, weekly_target_hours: 40 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    employments = @client.employments.all
    assert_equal 1, employments.size
    assert_instance_of MOCO::Employment, employments.first
  end

  # Test Purchase categories
  def test_get_purchase_categories
    stub_request(:get, "https://example.mocoapp.com/api/v1/purchases/categories")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Office Supplies" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    categories = @client.purchase_categories.all
    assert_equal 1, categories.size
    assert_instance_of MOCO::PurchaseCategory, categories.first
  end

  # Test Purchase drafts
  def test_get_purchase_drafts
    stub_request(:get, "https://example.mocoapp.com/api/v1/purchases/drafts")
      .to_return(
        status: 200,
        body: [{ id: 1, title: "Draft Purchase" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    drafts = @client.purchase_drafts.all
    assert_equal 1, drafts.size
    assert_instance_of MOCO::PurchaseDraft, drafts.first
  end

  # Test Tagging entity
  def test_get_taggings
    stub_request(:get, "https://example.mocoapp.com/api/v1/taggings")
      .to_return(
        status: 200,
        body: [{ id: 1, tag_id: 10, entity_type: "Project", entity_id: 100 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    taggings = @client.taggings.all
    assert_equal 1, taggings.size
    assert_instance_of MOCO::Tagging, taggings.first
  end

  # Test ExpenseTemplate entity
  def test_get_expense_templates
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/expense_templates")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Travel Expenses" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    templates = @client.expense_templates.all
    assert_equal 1, templates.size
    assert_instance_of MOCO::ExpenseTemplate, templates.first
  end

  # Test FixedCost entity
  def test_get_fixed_costs
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/fixed_costs")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Rent" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    costs = @client.fixed_costs.all
    assert_equal 1, costs.size
    assert_instance_of MOCO::FixedCost, costs.first
  end

  # Test InternalHourlyRate entity
  def test_get_internal_hourly_rates
    stub_request(:get, "https://example.mocoapp.com/api/v1/account/internal_hourly_rates")
      .to_return(
        status: 200,
        body: [{ id: 1, name: "Junior", rate: 50 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    rates = @client.internal_hourly_rates.all
    assert_equal 1, rates.size
    assert_instance_of MOCO::InternalHourlyRate, rates.first
  end

  # Test WorkTimeAdjustment entity
  def test_get_work_time_adjustments
    stub_request(:get, "https://example.mocoapp.com/api/v1/users/work_time_adjustments")
      .to_return(
        status: 200,
        body: [{ id: 1, date: "2024-01-15", hours: 2.0 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    adjustments = @client.work_time_adjustments.all
    assert_equal 1, adjustments.size
    assert_instance_of MOCO::WorkTimeAdjustment, adjustments.first
  end

  # Test nested resources on existing entities
  def test_project_contracts
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1")
      .to_return(
        status: 200,
        body: { id: 1, name: "Test Project" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    project = @client.projects.find(1)
    assert_respond_to project, :contracts
    assert_respond_to project, :payment_schedules
    assert_respond_to project, :recurring_expenses
  end

  def test_invoice_payments_and_reminders
    stub_request(:get, "https://example.mocoapp.com/api/v1/invoices/1")
      .to_return(
        status: 200,
        body: { id: 1, identifier: "INV-001", title: "Test Invoice" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    invoice = @client.invoices.find(1)
    assert_respond_to invoice, :payments
    assert_respond_to invoice, :reminders
    assert_respond_to invoice, :attachments
  end

  def test_user_employments_and_adjustments
    stub_request(:get, "https://example.mocoapp.com/api/v1/users/1")
      .to_return(
        status: 200,
        body: { id: 1, firstname: "Test", lastname: "User" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    user = @client.users.find(1)
    assert_respond_to user, :employments
    assert_respond_to user, :work_time_adjustments
  end

  # Test nested project resources
  def test_project_nested_contracts
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1")
      .to_return(
        status: 200,
        body: { id: 1, name: "Test Project" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1/contracts")
      .to_return(
        status: 200,
        body: [{ id: 1, user_id: 10, hourly_rate: 100 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    project = @client.projects.find(1)
    contracts = project.contracts.all
    assert_equal 1, contracts.size
    assert_instance_of MOCO::ProjectContract, contracts.first
  end

  def test_project_nested_payment_schedules
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1")
      .to_return(
        status: 200,
        body: { id: 1, name: "Test Project" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1/payment_schedules")
      .to_return(
        status: 200,
        body: [{ id: 1, date: "2024-01-15", amount: 1000 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    project = @client.projects.find(1)
    schedules = project.payment_schedules.all
    assert_equal 1, schedules.size
    assert_instance_of MOCO::PaymentSchedule, schedules.first
  end

  def test_project_nested_recurring_expenses
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1")
      .to_return(
        status: 200,
        body: { id: 1, name: "Test Project" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/1/recurring_expenses")
      .to_return(
        status: 200,
        body: [{ id: 1, title: "Monthly Fee", amount: 500 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    project = @client.projects.find(1)
    expenses = project.recurring_expenses.all
    assert_equal 1, expenses.size
    assert_instance_of MOCO::RecurringExpense, expenses.first
  end

  # Test nested invoice resources
  def test_invoice_nested_payments
    stub_request(:get, "https://example.mocoapp.com/api/v1/invoices/1")
      .to_return(
        status: 200,
        body: { id: 1, identifier: "INV-001", title: "Test Invoice" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:get, "https://example.mocoapp.com/api/v1/invoices/1/payments")
      .to_return(
        status: 200,
        body: [{ id: 1, date: "2024-01-20", amount: 500 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    invoice = @client.invoices.find(1)
    payments = invoice.payments.all
    assert_equal 1, payments.size
    assert_instance_of MOCO::InvoicePayment, payments.first
  end

  def test_invoice_nested_reminders
    stub_request(:get, "https://example.mocoapp.com/api/v1/invoices/1")
      .to_return(
        status: 200,
        body: { id: 1, identifier: "INV-001", title: "Test Invoice" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:get, "https://example.mocoapp.com/api/v1/invoices/1/reminders")
      .to_return(
        status: 200,
        body: [{ id: 1, date: "2024-02-01", level: 1 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    invoice = @client.invoices.find(1)
    reminders = invoice.reminders.all
    assert_equal 1, reminders.size
    assert_instance_of MOCO::InvoiceReminder, reminders.first
  end

  # Test offer status update
  def test_offer_pdf
    stub_request(:get, "https://example.mocoapp.com/api/v1/offers/1")
      .to_return(
        status: 200,
        body: { id: 1, identifier: "O-001", title: "Test Offer" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    stub_request(:get, "https://example.mocoapp.com/api/v1/offers/1.pdf")
      .to_return(
        status: 200,
        body: "%PDF-1.4 fake pdf content",
        headers: { "Content-Type" => "application/pdf" }
      )

    offer = @client.offers.find(1)
    pdf = offer.pdf
    assert_not_nil pdf
  end

  # Test reports cashflow and finance
  def test_reports_cashflow
    stub_request(:get, "https://example.mocoapp.com/api/v1/report/cashflow")
      .with(query: { from: "2024-01-01", to: "2024-01-31" })
      .to_return(
        status: 200,
        body: [{ month: "2024-01", amount: 10000 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @client.reports.cashflow(from: "2024-01-01", to: "2024-01-31")
    assert_kind_of Array, result
  end

  def test_reports_finance
    stub_request(:get, "https://example.mocoapp.com/api/v1/report/finance")
      .with(query: { from: "2024-01-01", to: "2024-01-31" })
      .to_return(
        status: 200,
        body: [{ category: "Revenue", amount: 50000 }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @client.reports.finance(from: "2024-01-01", to: "2024-01-31")
    assert_kind_of Array, result
  end
end
