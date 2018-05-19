defmodule Bank.Commands do
  defmodule CreateAccount do
    defstruct [:id]
  end

  defmodule DepositMoney do
    defstruct [:id, :amount]
  end

  defmodule WithdrawMoney do
    defstruct [:id, :amount]
  end
end