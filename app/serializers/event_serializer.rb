class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :descripton, :open_date, :close_date, :media, :thumbnail, :media_credit, :media_caption
end
