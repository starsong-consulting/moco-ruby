#!/usr/bin/env ruby
# frozen_string_literal: true

# Integration tests that hit the real MOCO API
# Run with: MOCO_API_TEST_SUBDOMAIN=xxx MOCO_API_TEST_API_KEY=xxx bundle exec ruby test/test_integration.rb

require_relative "test_helper"

class TestIntegration < Test::Unit::TestCase
  def setup
    skip_unless_configured
    @client = MOCO::Client.new(
      subdomain: ENV["MOCO_API_TEST_SUBDOMAIN"],
      api_key: ENV["MOCO_API_TEST_API_KEY"]
    )
  end

  def skip_unless_configured
    unless ENV["MOCO_API_TEST_SUBDOMAIN"] && ENV["MOCO_API_TEST_API_KEY"]
      omit("Integration tests require MOCO_API_TEST_SUBDOMAIN and MOCO_API_TEST_API_KEY environment variables")
    end
  end

  # Core entities (original)
  def test_profile
    profile = @client.profile
    assert_instance_of MOCO::Profile, profile
    assert_not_nil profile.id
    assert_not_nil profile.email
  end

  def test_users
    users = @client.users.all
    assert_kind_of Array, users
    assert users.all? { |u| u.is_a?(MOCO::User) }
  end

  def test_projects
    projects = @client.projects.all
    assert_kind_of Array, projects
    assert projects.all? { |p| p.is_a?(MOCO::Project) }
  end

  def test_companies
    companies = @client.companies.all
    assert_kind_of Array, companies
    assert companies.all? { |c| c.is_a?(MOCO::Company) }
  end

  def test_activities
    activities = @client.activities.all
    assert_kind_of Array, activities
    assert activities.all? { |a| a.is_a?(MOCO::Activity) }
  end

  def test_invoices
    invoices = @client.invoices.all
    assert_kind_of Array, invoices
    assert invoices.all? { |i| i.is_a?(MOCO::Invoice) }
  end

  def test_deals
    deals = @client.deals.all
    assert_kind_of Array, deals
    assert deals.all? { |d| d.is_a?(MOCO::Deal) }
  end

  # New standalone entities
  def test_contacts
    contacts = @client.contacts.all
    assert_kind_of Array, contacts
    assert contacts.all? { |c| c.is_a?(MOCO::Contact) }
  end

  def test_offers
    offers = @client.offers.all
    assert_kind_of Array, offers
    assert offers.all? { |o| o.is_a?(MOCO::Offer) }
  end

  def test_purchases
    purchases = @client.purchases.all
    assert_kind_of Array, purchases
    assert purchases.all? { |p| p.is_a?(MOCO::Purchase) }
  end

  def test_receipts
    receipts = @client.receipts.all
    assert_kind_of Array, receipts
    assert receipts.all? { |r| r.is_a?(MOCO::Receipt) }
  end

  def test_units
    units = @client.units.all
    assert_kind_of Array, units
    assert units.all? { |u| u.is_a?(MOCO::Unit) }
  end

  def test_comments
    comments = @client.comments.all
    assert_kind_of Array, comments
    assert comments.all? { |c| c.is_a?(MOCO::Comment) }
  end

  def test_tags
    tags = @client.tags.all
    assert_kind_of Array, tags
    assert tags.all? { |t| t.is_a?(MOCO::Tag) }
  end

  def test_deal_categories
    categories = @client.deal_categories.all
    assert_kind_of Array, categories
    assert categories.all? { |c| c.is_a?(MOCO::DealCategory) }
  end

  def test_project_groups
    groups = @client.project_groups.all
    assert_kind_of Array, groups
    assert groups.all? { |g| g.is_a?(MOCO::ProjectGroup) }
  end

  def test_schedules
    schedules = @client.schedules.all
    assert_kind_of Array, schedules
    assert schedules.all? { |s| s.is_a?(MOCO::Schedule) }
  end

  def test_planning_entries
    entries = @client.planning_entries.all
    assert_kind_of Array, entries
    assert entries.all? { |e| e.is_a?(MOCO::PlanningEntry) }
  end

  # Account-level entities
  def test_catalog_services
    services = @client.catalog_services.all
    assert_kind_of Array, services
    assert services.all? { |s| s.is_a?(MOCO::CatalogService) }
  end

  def test_custom_properties
    properties = @client.custom_properties.all
    assert_kind_of Array, properties
    assert properties.all? { |p| p.is_a?(MOCO::CustomProperty) }
  end

  def test_hourly_rates
    rates = @client.hourly_rates.all
    assert_kind_of Array, rates
    assert rates.all? { |r| r.is_a?(MOCO::HourlyRate) }
  end

  def test_internal_hourly_rates
    rates = @client.internal_hourly_rates.all
    assert_kind_of Array, rates
    assert rates.all? { |r| r.is_a?(MOCO::InternalHourlyRate) }
  end

  def test_task_templates
    templates = @client.task_templates.all
    assert_kind_of Array, templates
    assert templates.all? { |t| t.is_a?(MOCO::TaskTemplate) }
  end

  def test_expense_templates
    templates = @client.expense_templates.all
    assert_kind_of Array, templates
    assert templates.all? { |t| t.is_a?(MOCO::ExpenseTemplate) }
  end

  def test_fixed_costs
    costs = @client.fixed_costs.all
    assert_kind_of Array, costs
    assert costs.all? { |c| c.is_a?(MOCO::FixedCost) }
  end

  def test_user_roles
    roles = @client.user_roles.all
    assert_kind_of Array, roles
    assert roles.all? { |r| r.is_a?(MOCO::UserRole) }
  end

  # VAT codes
  def test_vat_code_sales
    codes = @client.vat_code_sales.all
    assert_kind_of Array, codes
    assert codes.all? { |c| c.is_a?(MOCO::VatCodeSale) }
  end

  def test_vat_code_purchases
    codes = @client.vat_code_purchases.all
    assert_kind_of Array, codes
    assert codes.all? { |c| c.is_a?(MOCO::VatCodePurchase) }
  end

  # User sub-resources
  def test_employments
    employments = @client.employments.all
    assert_kind_of Array, employments
    assert employments.all? { |e| e.is_a?(MOCO::Employment) }
  end

  def test_holidays
    holidays = @client.holidays.all
    assert_kind_of Array, holidays
    assert holidays.all? { |h| h.is_a?(MOCO::Holiday) }
  end

  def test_presences
    presences = @client.presences.all
    assert_kind_of Array, presences
    assert presences.all? { |p| p.is_a?(MOCO::Presence) }
  end

  # Purchase sub-resources
  def test_purchase_categories
    categories = @client.purchase_categories.all
    assert_kind_of Array, categories
    assert categories.all? { |c| c.is_a?(MOCO::PurchaseCategory) }
  end

  # Reports
  def test_reports_absences
    result = @client.reports.absences
    assert_kind_of Array, result
  end

  # Test CRUD operations (create and delete a contact)
  def test_contact_crud
    # Create
    contact = @client.contacts.create(
      firstname: "Test",
      lastname: "Integration#{Time.now.to_i}",
      gender: "U"
    )
    assert_instance_of MOCO::Contact, contact
    assert_not_nil contact.id
    assert_equal "Test", contact.firstname

    # Read
    fetched = @client.contacts.find(contact.id)
    assert_equal contact.id, fetched.id

    # Update
    updated = @client.contacts.update(contact.id, firstname: "Updated")
    assert_equal "Updated", updated.firstname

    # Delete
    @client.contacts.delete(contact.id)
  end

  # Test CRUD operations for tags
  def test_tag_crud
    # Create - note: API requires 'context' not 'entity'
    begin
      tag = @client.tags.create(
        name: "TestTag#{Time.now.to_i}",
        context: "Project"
      )
    rescue RuntimeError => e
      # Skip if we don't have permission to create tags
      omit("Tag creation not permitted: #{e.message}") if e.message.include?("403")
      raise
    end

    assert_instance_of MOCO::Tag, tag
    assert_not_nil tag.id

    # Update
    updated = @client.tags.update(tag.id, name: "UpdatedTag#{Time.now.to_i}")
    assert_not_nil updated.id

    # Delete
    @client.tags.delete(tag.id)
  end

  # Test CRUD operations for units
  def test_unit_crud
    # Create
    unit = @client.units.create(name: "TestUnit#{Time.now.to_i}")
    assert_instance_of MOCO::Unit, unit
    assert_not_nil unit.id

    # Update
    updated = @client.units.update(unit.id, name: "UpdatedUnit#{Time.now.to_i}")
    assert_not_nil updated.id

    # Delete
    @client.units.delete(unit.id)
  end

  # Test web hooks
  def test_web_hooks
    hooks = @client.web_hooks.all
    assert_kind_of Array, hooks
    assert hooks.all? { |h| h.is_a?(MOCO::WebHook) }
  end

  # Bookkeeping exports
  def test_invoice_bookkeeping_exports
    exports = @client.invoice_bookkeeping_exports.all
    assert_kind_of Array, exports
    assert exports.all? { |e| e.is_a?(MOCO::InvoiceBookkeepingExport) }
  end

  def test_purchase_bookkeeping_exports
    exports = @client.purchase_bookkeeping_exports.all
    assert_kind_of Array, exports
    assert exports.all? { |e| e.is_a?(MOCO::PurchaseBookkeepingExport) }
  end

  # Purchase budgets (read-only)
  def test_purchase_budgets
    budgets = @client.purchase_budgets.all
    assert_kind_of Array, budgets
    assert budgets.all? { |b| b.is_a?(MOCO::PurchaseBudget) }
  end

  # Purchase payments
  def test_purchase_payments
    payments = @client.purchase_payments.all
    assert_kind_of Array, payments
    assert payments.all? { |p| p.is_a?(MOCO::PurchasePayment) }
  end
end
