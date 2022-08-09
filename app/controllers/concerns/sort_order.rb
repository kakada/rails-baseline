# frozen_string_literal: true

module SortOrder
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction

    private
      def responsibility_model
        controller_name.classify.constantize
      end

      def sort_column
        responsibility_model.column_names.include?(params[:sort]) ? params[:sort] : default_sort_column
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
      end

      def default_sort_column
        "created_at"
      end

      def default_sort_direction
        "desc"
      end

      def sort_param
        sort_column + " " + sort_direction
      end
  end
end
