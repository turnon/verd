module RailsERD
  class Domain
    class Relationship

      NoneSym = 'none'
      HasManySym ='rect'
      HasOneSym = 'triangle'

      def verd_link
        src, tar, sym = nil, nil, nil

        associations.each do |asso|
          if asso.macro == :has_many
            src, tar, sym = asso.active_record.to_s, asso.klass.to_s, HasManySym
            break
          elsif asso.macro == :has_one
            src, tar, sym = asso.active_record.to_s, asso.klass.to_s, HasOneSym
          else
            break if sym
            src, tar, sym = asso.klass.to_s, asso.active_record.to_s, HasManySym
          end
        end

        {source: src, target: tar, symbol: [NoneSym, sym]}
      end
    end
  end
end
