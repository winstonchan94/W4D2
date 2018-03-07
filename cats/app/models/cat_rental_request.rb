# == Schema Information
#
# Table name: cat_rental_requests
#
#  id         :integer          not null, primary key
#  cat_id     :integer          not null
#  start_date :date             not null
#  end_date   :date             not null
#  status     :string           default("PENDING"), not null
#

class CatRentalRequest < ApplicationRecord

  STATUSES = ['PENDING', 'APPROVED', 'DENIED'].freeze

  validates :cat_id, :start_date, :end_date, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  validate :does_not_overlap_approved_request
  validate :start_date_before_end_date
  validate :start_date_after_current_date

  belongs_to :cat,
    class_name: :Cat,
    primary_key: :id,
    foreign_key: :cat_id

  def overlapping_requests
    CatRentalRequest.where(cat_id: cat_id)
      .where.not(id: id)
      .where(<<-SQL, our_start: start_date, our_end: end_date)
        start_date BETWEEN :our_start AND :our_end
      OR
        end_date BETWEEN :our_start AND :our_end
      OR
        (start_date < :our_start AND end_date > :our_end)
      SQL
  end

  def overlapping_approved_requests
    self.overlapping_requests.where(status: 'APPROVED')
  end

  def deny!
    update!(status: 'DENIED')
  end

  def approve!
    ActiveRecord::Base.transaction do
      update!(status: 'APPROVED')
      overlapping_requests.where(status: 'PENDING').each(&:deny!)
    end
  end

  def denied?
    status == 'DENIED'
  end

  def pending?
    status == 'PENDING'
  end

  def does_not_overlap_approved_request
    if !denied? && self.overlapping_approved_requests.exists?
      errors.add(:date_range, "cannot overlap an existing approved request")
    end
  end

  def start_date_before_end_date
    if start_date.nil? || end_date.nil? || start_date > end_date
      errors.add(:start_date, "must be before end date")
    end
  end

  def start_date_after_current_date
    if start_date.nil? || start_date <= Date.today
      errors.add(:start_date, "must be a future date")
    end
  end
end
