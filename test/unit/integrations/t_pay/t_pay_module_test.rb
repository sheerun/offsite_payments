require 'test_helper'

class TPayTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_helper
    assert_instance_of TPay::Helper, TPay.helper('', '')
  end

  def test_notification
    assert_instance_of TPay::Notification, TPay.notification('')
  end

  def test_return
    assert_instance_of TPay::Return, TPay.return('')
  end

  def test_sign
    assert_equal Digest::MD5.hexdigest('foobarbazqux'),
                 TPay.sign('foo', 'bar', 'baz', 'qux')
  end
end
