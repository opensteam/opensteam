pdf.image RAILS_ROOT + '/public/images/opensteam_store_logo.jpg', :scale => 0.3

pdf.text "Invoice ##{@invoice.id}, Order ##{@order.id}", :size => 25, :align => :center
pdf.stroke_horizontal_rule

pdf.text "\n\n"

pdf.text "Customer Information", :style => :bold
pdf.text "\n"
pdf.text "Email: #{@order.customer.email}", :size => 8
pdf.text "Firstname: #{@order.customer.firstname}", :size => 8
pdf.text "Lastname: #{@order.customer.lastname}", :size => 8
pdf.text "\n\n"
pdf.text "Shipping Information", :style => :bold
pdf.text "\n"
pdf.font.size(8) do
    pdf.text "Shipping Type: #{@order.shipping_type}"
    pdf.text "\n"
    pdf.text "Address", :style => :bold, :size => 8
    pdf.text @order.shipping_address.to_a
end

pdf.text "\n\n"

pdf.text "Billing Information", :style => :bold
pdf.text "\n"
pdf.font.size(8) do
    pdf.text "Payment Type: #{Opensteam::Payment::Base[ @order.payment_type ].display_name}"
    pdf.text "\n"
    pdf.text "Address", :style => :bold, :size => 8
    pdf.text @order.payment_address.to_a
end

pdf.text "\n\n"

pdf.text "Order Items", :style => :bold
pdf.text "\n"
pdf.table( @invoice.items.collect { |i|
    [ i.item.id, i.item.name, i.item.product.class, i.item.properties.join(","), i.quantity, i.price, i.tax, i.total_price ] } +
    [   [ "", "Total Netto Price", "", "", "", "", "", @invoice.items.collect(&:total_price).sum - @invoice.items.collect(&:tax).sum ],
        [ "", "Total Tax", "", "", "", "", "", @invoice.items.collect(&:tax).sum ],
        [ "", "Shipping Rate", "", "", "", "", "", @order.shipping_rate ],
        [ "", "", "", "", "", "", "", "" ],
        [ "", "Total Price", "", "", "", "", "", @invoice.price + @order.shipping_rate ] 
    ],
    :font_size => 7,
    :horizontal_padding => 10,
    :vertical_padding   => 3,
:row_colors => ["FFFFFF", "DDDDDD" ],
    :border_width       => 1,
    :position           => :left,
    :headers            => ["ID","Name", "Class", "Information", "Quantity", "Single Price", "Tax", "Total Price"] )


pdf.text "\n\n"

pdf.text "Comment", :style => :bold
pdf.text "\n"
pdf.text @invoice.comment, :size => 8
