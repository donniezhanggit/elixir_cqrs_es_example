defmodule Bank.CommandHandlerTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.BankService

  setup_all do
    {:ok, _pid} = start_supervised Bank.CommandHandler
    :ok
  end

  describe "on create account command" do
    test "an account is created" do
      with_mock BankService, [create_account: fn(_) -> :ok end] do
        send_command(%CreateAccount{id: "Joe"})

        assert called BankService.create_account("Joe")
      end
    end
  end

  describe "on deposit money command" do
    test "an amount is deposited" do
      with_mock BankService, [deposit_money: fn(_, _) -> :ok end] do
        send_command(%DepositMoney{id: "Joe", amount: 100})

        assert called BankService.deposit_money("Joe", 100)
      end
    end
  end

  describe "on withdraw money command" do
    test "an amount is withdrawn" do
      with_mock BankService, [withdraw_money: fn(_, _) -> :ok end] do
        send_command(%WithdrawMoney{id: "Joe", amount: 100})

        assert called BankService.withdraw_money("Joe", 100)
      end
    end
  end

  defp send_command(command), do: GenServer.call(:command_handler, command)
end