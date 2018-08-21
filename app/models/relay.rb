# frozen_string_literal: true
# == Schema Information
#
# Table name: relays
#
#  id                 :bigint(8)        not null, primary key
#  inbox_url          :string           default(""), not null
#  follow_activity_id :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  state              :integer          default("idle"), not null
#

class Relay < ApplicationRecord
  PRESET_RELAY = 'https://relay.joinmastodon.org/inbox'

  validates :inbox_url, presence: true, uniqueness: true, url: true, if: :will_save_change_to_inbox_url?

  enum state: [:idle, :pending, :accepted, :rejected]

  scope :enabled, -> { accepted }

  before_destroy :ensure_disabled

  alias enabled? accepted?

  def enable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(follow_activity(activity_id))

    update!(state: :pending, follow_activity_id: activity_id)
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  def disable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(unfollow_activity(activity_id))

    update!(state: :idle, follow_activity_id: nil)
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  private

  def follow_activity(activity_id)
    {
      '@context': ActivityPub::TagManager::CONTEXT,
      id: activity_id,
      type: 'Follow',
      actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
      object: ActivityPub::TagManager::COLLECTIONS[:public],
    }
  end

  def unfollow_activity(activity_id)
    {
      '@context': ActivityPub::TagManager::CONTEXT,
      id: activity_id,
      type: 'Undo',
      actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
      object: {
        id: follow_activity_id,
        type: 'Follow',
        actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
        object: ActivityPub::TagManager::COLLECTIONS[:public],
      },
    }
  end

  def some_local_account
    @some_local_account ||= Account.local.find_by(suspended: false)
  end

  def ensure_disabled
    return unless enabled?
    disable!
  end
end