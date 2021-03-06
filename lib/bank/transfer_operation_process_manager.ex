defmodule Bank.TransferOperationProcessManager do
  @behaviour Bank.ProcessManager

  alias Bank.Events
  alias Bank.Commands

  @impl true
  def on(%Events.TransferOperationOpened{} = event, %{} = operations) do
    :ok = command_bus().send(%Commands.ConfirmTransferOperation{
      account_id: event.payee,
      payer: event.id,
      amount: event.amount,
      operation_id: event.operation_id
    })

    switch(operations, to: :pending_confirmation, for: event.operation_id)
  end

  @impl true
  def on(%Events.TransferOperationConfirmed{} = event, %{} = operations) do
    :ok = command_bus().send(%Commands.CompleteTransferOperation{
      account_id: event.payer,
      payee: event.id,
      amount: event.amount,
      operation_id: event.operation_id
    })

    switch(operations, to: :complete, for: event.operation_id)
  end

  @impl true
  def on(_not_handled_event, operations) do
    operations
  end

  defp switch(operations, to: next_state, for: operation_id) do
    Map.put(operations, operation_id, next_state)
  end

  defp command_bus() do
    Application.get_env(:elixir_cqrs_es_example, :command_bus)
  end
end
