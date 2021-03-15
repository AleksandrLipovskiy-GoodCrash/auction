defmodule Auction.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bids" do
    field :amount, :integer

    belongs_to :item, Auction.Item
    belongs_to :user, Auction.User

    timestamps()
  end

  def changeset(bid, params \\ %{}) do
    bid
    |> cast(params, [:amount, :user_id, :item_id])
    |> validate_required([:amount, :user_id, :item_id])
    |> assoc_constraint(:item)
    |> assoc_constraint(:user)
    |> validate_amount()
  end

  defp validate_amount(%Ecto.Changeset{changes: %{amount: amount, item_id: item_id}} = changeset) do
    last_bid = Auction.get_last_bid_for_item(item_id)
    auction_ends_at = Auction.get_item(item_id).ends_at

    cond do
      amount <= 0 ->
        add_error(changeset, :amount, "must be greater zero")

      amount <= last_bid.amount ->
        add_error(changeset, :amount, "must be greater than the last bet amount")

      DateTime.compare(auction_ends_at, DateTime.utc_now()) == :lt ->
        add_error(changeset, :amount, "bids are not accepted on expired item")

      true ->
        changeset
    end
  end

  defp validate_amount(changeset), do: changeset
end