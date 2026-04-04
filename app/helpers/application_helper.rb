module ApplicationHelper
    def amenity_icon(slug, css_class: "h-6 w-6")
      known_slugs = %w[
        wifi kitchen washer dryer essentials workspace ethernet tv streaming
        books hangers iron hair-dryer extra-pillows blackout-blinds free-parking
        paid-parking ev-charger lift gym smoke-alarm co-alarm fire-extinguisher
        first-aid-kit security-cameras lockbox bathtub hot-water shower-gel
        shampoo conditioner refrigerator microwave cooking-basics dishes-silverware
        dishwasher oven stove coffee-maker kettle toaster air-conditioning heating
        ceiling-fan fireplace pool hot-tub bbq-grill outdoor-dining garden
        beach-access waterfront mountain-view near-beach crib high-chair
        children-books pets-allowed
      ]

      icon_id = known_slugs.include?(slug) ? "icon-#{slug}" : "icon-default"

      content_tag(:svg, class: css_class, "aria-hiddem": "true", focusable: "false") do
        content_tag(:use, "", href: "##{icon_id}")
      end
    end
end
