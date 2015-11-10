require 'test_helper'

class TPayNotificationTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @account       = 'test-shop-id'
    @security_code = 'security_code'

    @t_pay = TPay::Notification.new http_raw_data,
      id:            @account,
      security_code: @security_code
  end

  def test_accessors
    assert @t_pay.complete?
    assert_equal '123',                              @t_pay.transaction_id
    assert_equal '1-2-3000',                         @t_pay.received_at
    assert_equal 'crc',                              @t_pay.crc
    assert_equal 'test@test.test',                   @t_pay.payer_email
    assert_equal '12.34',                            @t_pay.gross
    assert_equal 'PLN',                              @t_pay.currency
    assert_equal 'TRUE',                             @t_pay.status
    assert_equal 'none',                             @t_pay.error
    assert_equal 'test',                             @t_pay.desc
    assert_equal 'c0fea7eac4282be7be294c544a958e51', @t_pay.md5sum
    refute @t_pay.test?
  end

  def test_compositions
    assert_equal Money.new(1234, 'PLN'), @t_pay.amount
  end

  def test_respond_to_acknowledge
    assert @t_pay.respond_to?(:acknowledge)
  end

  def test_acknowledgement
    assert @t_pay.acknowledge
  end

  private

  def http_raw_data
    <<-DATA.gsub(/^\s+/, '').gsub(/\n/, '&').sub(/&\Z/, '')
      tr_id=123
      tr_date=1-2-3000
      tr_crc=crc
      tr_amount=12.34
      tr_paid=12.34
      tr_desc=test
      tr_status=TRUE
      tr_error=none
      tr_email=test@test.test
      md5sum=c0fea7eac4282be7be294c544a958e51
      test_mode=0
    DATA
  end
end
