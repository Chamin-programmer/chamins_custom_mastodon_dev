# frozen_string_literal: true

class InstanceStatsController < ApplicationController
  include WebAppControllerConcern

  skip_before_action :require_functional!

  before_action :set_instance_presenter

  def show
    expires_in 3.minutes, public: true
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
