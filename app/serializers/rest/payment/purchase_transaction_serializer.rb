class REST::Payment::PurchaseTransactionSerializer < ActiveModel::Serializer
  attributes :id, :service, :product, :purchased
end
