module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module TPay
      mattr_accessor :service_url
      self.service_url = 'https://secure.tpay.com'

      def self.helper(order, account, options = {})
        Helper.new(order, account, options)
      end

      def self.notification(post, options = {})
        Notification.new(post, options)
      end

      def self.return(query_string, options = {})
        Return.new(query_string, options)
      end

      def self.sign(*fields)
        Digest::MD5.hexdigest(fields.map(&:to_s).join(''))
      end

      class Helper < OffsitePayments::Helper
        def initialize(order, account, options = {})
          self.security_code = options.delete(:credential3)

          super

          self.language       = 'PL'
          self.filter_offline = 1
        end

        mapping :order,   'opis'
        mapping :account, 'id'
        mapping :amount,  'kwota'

        mapping :language,      'jezyk'

        mapping :credential2,    'crc'
        mapping :checksum,       'md5sum'
        mapping :filter_offline, 'online'

        mapping :customer, name:  'nazwisko',
                           email: 'email',
                           phone: 'telefon'

        mapping :billing_address, city:    'miasto',
                                  address: 'adres',
                                  zip:     'kod',
                                  kraj:    'kraj'

        mapping :notify_url,        'wyn_url'
        mapping :notify_email,      'wyn_email'
        mapping :return_url,        'pow_url'
        mapping :cancel_return_url, 'pow_url_blad'

        def form_fields
          fields.merge(mappings[:checksum] => generate_signature)
        end

        private

        attr_accessor :security_code

        def generate_signature
          TPay.sign(fields['id'], fields['kwota'], fields['crc'], security_code)
        end
      end

      class Notification < OffsitePayments::Notification
        self.production_ips = ['195.149.229.109']

        def initialize(post, options = {})
          self.id            = options.delete(:id)
          self.security_code = options.delete(:security_code)

          super
        end

        def complete?
          md5sum == generate_signature && status == 'TRUE'
        end

        def transaction_id
          params['tr_id']
        end

        def received_at
          params['tr_date']
        end

        def crc
          params['tr_crc']
        end

        def payer_email
          params['tr_email']
        end

        def gross
          params['tr_amount']
        end

        def currency
          'PLN'
        end

        def desc
          params['tr_desc']
        end

        def error
          params['tr_error']
        end

        def md5sum
          params['md5sum']
        end

        def status
          params['tr_status']
        end

        def test?
          params['test_mode'] != '0'
        end

        def acknowledge(authcode = nil)
          true
        end

        private

        attr_accessor :id, :security_code

        def generate_signature
          TPay.sign(id, transaction_id, amount, crc, security_code)
        end
      end

      Return = Class.new(OffsitePayments::Return)
    end
  end
end
