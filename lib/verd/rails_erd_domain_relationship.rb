module RailsERD
  class Domain
    class Relationship

      NoneSym = 'none'
      HasManySym ='rect'
      HasOneSym = 'triangle'

      def verd_link
        src, tar, macro = nil, nil, nil

        associations.each do |asso|
          if asso.macro == :has_many
            src, tar, macro = asso.active_record.to_s, asso.klass.to_s, :has_many
            break
          elsif asso.macro == :has_one
            src, tar, macro = asso.active_record.to_s, asso.klass.to_s, :has_one
          else
            break if macro
            src, tar, macro = asso.klass.to_s, asso.active_record.to_s, :has_many
          end
        end

        sym = macro == :has_many ? HasManySym : HasOneSym
        {source: src, target: tar, macro: macro, symbol: [NoneSym, sym]}
      end
    end
  end
end
