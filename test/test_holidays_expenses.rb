#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "test_helper"

class TestHolidaysExpenses < Test::Unit::TestCase
  def setup
    @client = MOCO::Client.new(
      subdomain: ENV["MOCO_API_TEST_SUBDOMAIN"],
      api_key: ENV["MOCO_API_TEST_API_KEY"]
    )
  end

  # Holidays (Per-User Resource)
  sub_test_case "Holidays API" do
    setup do
      @user = @client.users.first
    end

    test "fetch all holidays" do
      holidays = @client.holidays.all
      assert_instance_of Array, holidays
    end

    test "fetch holidays filtered by year" do
      holidays = @client.holidays.where(year: 2025).all
      assert_instance_of Array, holidays
    end

    test "fetch holidays filtered by user" do
      holidays = @client.holidays.where(user_id: @user.id).all
      assert_instance_of Array, holidays
    end

    test "full CRUD lifecycle" do
      # CREATE
      holiday = @client.holidays.create(
        year: 2025,
        title: "Test Holiday",
        hours_per_day: 8,
        user_id: @user.id
      )
      assert_not_nil holiday.id

      # READ
      found = @client.holidays.find(holiday.id)
      assert_equal holiday.id, found.id

      # DELETE
      result = @client.holidays.delete(holiday.id)
      assert result
    end
  end

  # Expenses (Nested Under Projects)
  sub_test_case "Expenses API" do
    setup do
      @project = @client.projects.all.first
    end

    test "fetch all expenses globally" do
      expenses = @client.expenses.all
      assert_instance_of Array, expenses
    end

    test "fetch project expenses" do
      expenses = @project.expenses.all
      assert_instance_of Array, expenses
    end

    test "full CRUD lifecycle through project" do
      # CREATE
      expense = @project.expenses.create(
        date: Date.today.to_s,
        title: "Test Expense #{Time.now.to_i}",
        quantity: 2,
        unit: "hours",
        unit_price: 100.0,
        unit_cost: 50.0,
        billable: true
      )
      assert_not_nil expense.id
      assert_equal "Test Expense #{expense.attributes[:title].split.last}", expense.title

      # READ
      found = @project.expenses.find(expense.id)
      assert_equal expense.id, found.id

      # UPDATE
      updated = @project.expenses.update(expense.id,
        title: "Updated Expense",
        quantity: 3
      )
      assert_equal "Updated Expense", updated.title
      assert_equal 3.0, updated.quantity

      # Verify in global list
      all_expenses = @client.expenses.all
      assert_instance_of Array, all_expenses

      # DELETE
      result = @project.expenses.delete(expense.id)
      assert result
    end

    test "expense associations" do
      # Create an expense first
      expense = @project.expenses.create(
        date: Date.today.to_s,
        title: "Association Test",
        quantity: 1,
        unit: "piece",
        unit_price: 10.0,
        unit_cost: 5.0
      )

      # Test associations
      if expense.project
        assert_instance_of MOCO::Project, expense.project
      end

      if expense.user
        assert_instance_of MOCO::User, expense.user
      end

      # Cleanup
      @project.expenses.delete(expense.id)
    end
  end

  # Combined operations
  sub_test_case "Combined Operations" do
    test "create holiday and expense in same session" do
      user = @client.users.first
      project = @client.projects.all.first

      # Create holiday
      holiday = @client.holidays.create(
        year: 2025,
        title: "Combined Test Holiday",
        hours_per_day: 8,
        user_id: user.id
      )
      assert_not_nil holiday.id

      # Create expense
      expense = project.expenses.create(
        date: Date.today.to_s,
        title: "Combined Test Expense",
        quantity: 1,
        unit: "piece",
        unit_price: 50.0,
        unit_cost: 25.0
      )
      assert_not_nil expense.id

      # Cleanup
      @client.holidays.delete(holiday.id)
      project.expenses.delete(expense.id)
    end
  end
end
