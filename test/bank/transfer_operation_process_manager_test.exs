defmodule Bank.TransferOperationProcessManagerTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.Events
  alias Bank.CommandBusMock, as: CommandBus

  alias Bank.TransferOperationProcessManager, as: ProcessManager

  describe "on TransferOperationOpened" do
    setup do
      transfer_operation_opened =
        %Events.TransferOperationOpened{
          id: "payer_account",
          amount: 100,
          payee: "payee_account",
          operation_id: "OPERATION_ID"
        }

      %{event: transfer_operation_opened}
    end

    test "the operation goes to the state pending_confirmation", %{event: transfer_operation_opened} do
      stub(CommandBus, :send, fn(_) -> :ok end)

      new_state = ProcessManager.on(transfer_operation_opened, %{})

      assert new_state == %{
        "OPERATION_ID" => :pending_confirmation
      }
    end

    test "a command is sent to the payee to confirm the operation", %{event: transfer_operation_opened} do
      command = %Bank.Commands.ConfirmTransferOperation{
        id: transfer_operation_opened.payee,
        payer: transfer_operation_opened.id,
        amount: transfer_operation_opened.amount,
        operation_id: transfer_operation_opened.operation_id
      }

      expect(CommandBus, :send, fn(^command) -> :ok end)

      ProcessManager.on(transfer_operation_opened, %{})

      verify!(CommandBus)
    end
  end

  describe "on TransferOperationConfirmed" do
    test "TODO" do
      assert false
    end
  end

  describe "on a not handled event" do
    test "does not change the current state" do
      current_state = %{}
      new_state = ProcessManager.on(:not_handled_event, current_state)

      assert new_state == current_state
    end
  end
end