module Api
  module V1
    class FeesController < BaseController
      def index
        authorize!("fees.read")
        scope = FeeInvoice.includes(:fee_invoice_items, :student)
        scope = scope.where(student_id: params[:student_id]) if params[:student_id].present?
        scope = scope.where(student_id: family_student_ids) if family?
        render json: scope.order(due_date: :desc).map { |i|
          { id: i.id, number: i.number, student: i.student.name, period: i.period,
            issue_date: i.issue_date, due_date: i.due_date, status: i.status,
            total: i.total.to_f, paid: i.paid.to_f, balance: i.balance.to_f, overdue: i.overdue?,
            items: i.fee_invoice_items.map { { description: it.description, amount: it.amount.to_f } } }
        }
      end

      def pay
        authorize!("fees.collect")
        invoice = FeeInvoice.find(params[:id])
        payment = invoice.fee_payments.new(params.expect(payment: [:amount, :method, :reference, :gateway, :gateway_ref])
                                                 .merge(received_by: current_user))
        return render(json: { error: "invalid", details: payment.errors.to_hash }, status: :unprocessable_entity) unless payment.save

        render json: { receipt_id: payment.id, amount: payment.amount.to_f,
                       invoice: { id: invoice.id, balance: invoice.reload.balance.to_f, status: invoice.status } },
               status: :created
      end

      private

      def family? = current_user.kind.in?(%w[parent student])
      def family_student_ids
        current_user.student ? [current_user.student.id] : current_user.guardian&.students&.ids.to_a
      end
    end
  end
end
