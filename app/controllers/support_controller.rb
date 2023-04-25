# frozen_string_literal: true

class SupportController < ApplicationController
  def show
    instance_presenter = InstancePresenter.new
    @body = instance_presenter.site_support || ""
  end
end
