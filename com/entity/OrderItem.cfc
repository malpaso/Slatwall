/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component displayname="Order Item" entityname="SlatwallOrderItem" table="SlatwallOrderItem" persistent="true" accessors="true" output="false" extends="BaseEntity" {
	
	// Persistent Properties
	property name="orderItemID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="price" ormtype="big_decimal";
	property name="skuPrice" ormtype="big_decimal";
	property name="currencyCode" ormtype="string" length="3";
	property name="quantity" ormtype="integer";
	property name="estimatedFulfillmentDateTime" ormtype="timestamp";
	
	// Related Object Properties (many-to-one)
	property name="appliedPriceGroup" cfc="PriceGroup" fieldtype="many-to-one" fkcolumn="appliedPriceGroupID";
	property name="orderItemType" cfc="Type" fieldtype="many-to-one" fkcolumn="orderItemTypeID";
	property name="orderItemStatusType" cfc="Type" fieldtype="many-to-one" fkcolumn="orderItemStatusTypeID";
	property name="sku" cfc="Sku" fieldtype="many-to-one" fkcolumn="skuID" cascadeCalculate="true";
	property name="stock" cfc="Stock" fieldtype="many-to-one" fkcolumn="stockID";
	property name="order" cfc="Order" fieldtype="many-to-one" fkcolumn="orderID" cascadeCalculate="true";
	property name="orderFulfillment" cfc="OrderFulfillment" fieldtype="many-to-one" fkcolumn="orderFulfillmentID";
	property name="orderReturn" cfc="OrderReturn" fieldtype="many-to-one" fkcolumn="orderReturnID";
	property name="referencedOrderItem" cfc="OrderItem" fieldtype="many-to-one" fkcolumn="referencedOrderItemID"; // Used For Returns. This is set when this order is a return.
	
	// Related Object Properties (one-to-many)
	property name="appliedPromotions" singularname="appliedPromotion" cfc="PromotionApplied" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all-delete-orphan";
	property name="appliedTaxes" singularname="appliedTax" cfc="TaxApplied" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all-delete-orphan";
	property name="attributeValues" singularname="attributeValue" cfc="AttributeValue" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all-delete-orphan";
	property name="orderDeliveryItems" singularname="orderDeliveryItem" cfc="OrderDeliveryItem" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all";
	property name="stockReceiverItems" singularname="stockReceiverItem" cfc="StockReceiverItem" type="array" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true";
	property name="referencingOrderItems" singularname="referencingOrderItem" cfc="OrderItem" fieldtype="one-to-many" fkcolumn="referencedOrderItemID" inverse="true" cascade="all"; // Used For Returns
	
	// Remote properties
	property name="remoteID" ormtype="string";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non persistent properties
	property name="discountAmount" persistent="false" formatType="currency" hint="This is the discount amount after quantity (talk to Greg if you don't understand)" ;
	property name="extendedPrice" persistent="false" formatType="currency";
	property name="extendedPriceAfterDiscount" persistent="false" formatType="currency" ; 
	property name="quantityDelivered" persistent="false";
	property name="quantityUndelivered" persistent="false";
	property name="quantityReceived" persistent="false";
	property name="quantityUnreceived" persistent="false";
	property name="taxAmount" persistent="false" formatType="currency" ;
	property name="itemTotal" persistent="false" formatType="currency" ; 


	public numeric function getMaximumOrderQuantity() {
		var maxQTY = 0;
		
		if(getSku().getActiveFlag() && getSku().getProduct().getActiveFlag()) {
			maxQTY = getSku().setting('skuOrderMaximumQuantity');
			
			if(getSku().setting('skuTrackInventoryFlag') && !getSku().setting('skuAllowBackorderFlag')) {
				if( !isNull(getStock()) && getStock().getQuantity('QATS') < maxQTY ) {
					maxQTY = getStock().getQuantity('QATS');
				} else if(getSKU().getQuantity('QATS') < maxQTY) {
					maxQTY = getSku().getQuantity('QATS');
				}
			}	
		}
		
		return maxQTY;
	}
	
	public boolean function hasQuantityWithinMaxOrderQuantity() {
		return getQuantity() <= getMaximumOrderQuantity();
	}
	
	public string function getStatus(){
		return getOrderItemStatusType().getType();
	}
	
	public string function getStatusCode() {
		return getOrderItemStatusType().getSystemCode();
	}
	
	public string function getType(){
		return getOrderItemType().getType();
	}
	
	public string function getTypeCode(){
		return getOrderItemType().getSystemCode();
	}
	
	public string function displayCustomizations(format="list") {
		var customizations = "";
		if(arguments.format == 'htmlList' && this.hasAttributeValue()) {
			customizations = "<ul>";
		}
		for(var i=1; i<=arrayLen(getAttributeValues()); i++) {
			if(len(customizations) && arguments.format == "list") {
				customizations &= ", ";
			} else if(arguments.format == "htmlList") {
				customizations &= "<li>";
			}
			customizations &= "#getAttributeValues()[i].getAttribute().getAttributeName()#: #getAttributeValues()[i].getAttributeValue()#";
			if(arguments.format == "htmlList") {
				customizations &= "</li>";
			}
		}
		if(arguments.format == "htmlList") {
			customizations &= "</ul>";
		}		
		return customizations;
	}
 
    // This method returns a single percentage rate for all taxes. So an item with tax 5% and 8% would return 13.
    public numeric function getCombinedTaxRate() {
    	var taxRate = 0;
    	for(var i=1; i <= ArrayLen(getAppliedTaxes()); i++) {
    		taxRate = precisionEvaluate(taxRate + getAppliedTaxes()[i].getTaxRate());
    	}
    	
    	return taxRate;
    }
    
    public struct function getQuantityPriceAlreadyReturned() {
    	return getService("OrderService").getQuantityPriceSkuAlreadyReturned(getOrder().getOrderID(), getSku().getSkuID());
    }
    
   
	// ============ START: Non-Persistent Property Methods =================
	
	public numeric function getDiscountAmount() {
		var discountAmount = 0;
		
		for(var i=1; i<=arrayLen(getAppliedPromotions()); i++) {
			discountAmount = precisionEvaluate(discountAmount + getAppliedPromotions()[i].getDiscountAmount());
		}
		
		return discountAmount;
	}
	
	public numeric function getExtendedPrice() {
		return precisionEvaluate(getPrice() * getQuantity());
	}
	
	public numeric function getExtendedSkuPrice() {
		return precisionEvaluate(getSkuPrice() * getQuantity());
	}
	
	public numeric function getExtendedPriceAfterDiscount() {
		return precisionEvaluate(getExtendedPrice() - getDiscountAmount());
	}
	
	public numeric function getTaxAmount() {
		var taxAmount = 0;
		
		for(var i=1; i<=arrayLen(getAppliedTaxes()); i++) {
			taxAmount = precisionEvaluate(taxAmount + getAppliedTaxes()[i].getTaxAmount());
		}
		
		return taxAmount;
	}
	
	public numeric function getQuantityDelivered() {
		var quantityDelivered = 0;
		
		for( var i=1; i<=arrayLen(getOrderDeliveryItems()); i++){
			quantityDelivered += getOrderDeliveryItems()[i].getQuantity();
		}
		
		return quantityDelivered;
	}
	
	public numeric function getQuantityReceived() {
		var quantityReceived = 0;
		
		for( var i=1; i<=arrayLen(getStockReceiverItems()); i++){
			quantityReceived += getStockReceiverItems()[i].getQuantity();
		}
		
		return quantityReceived;
	}
	
	public numeric function getQuantityUnreceived() {
		return getQuantity() - getQuantityReceived();
	}
	
	public numeric function getQuantityUndelivered() {
		return getQuantity() - getQuantityDelivered();
	}
	
	public numeric function getItemTotal() {
		return precisionEvaluate(getTaxAmount() + getExtendedPriceAfterDiscount());
	}
	
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// Order (many-to-one)
	public void function setOrder(required any order) {
		variables.order = arguments.order;
		if(isNew() or !arguments.order.hasOrderItem( this )) {
			arrayAppend(arguments.order.getOrderItems(), this);
		}
	}
	public void function removeOrder(any order) {
		if(!structKeyExists(arguments, "order")) {
			arguments.order = variables.order;
		}
		var index = arrayFind(arguments.order.getOrderItems(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.order.getOrderItems(), index);
		}
		
		// Remove from order fulfillment to trigger those actions
		removeOrderFulfillment();

		structDelete(variables, "order");
	}
	
	// Order Fulfillment (many-to-one)
	public void function setOrderFulfillment(required any orderFulfillment) {
		variables.orderFulfillment = arguments.orderFulfillment;
		if(isNew() or !arguments.orderFulfillment.hasOrderFulfillmentItem( this )) {
			arrayAppend(arguments.orderFulfillment.getOrderFulfillmentItems(), this);
		}
	}
	public void function removeOrderFulfillment(any orderFulfillment) {
		if(!structKeyExists(arguments, "orderFulfillment")) {
			arguments.orderFulfillment = variables.orderFulfillment;
		}
		var index = arrayFind(arguments.orderFulfillment.getOrderFulfillmentItems(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.orderFulfillment.getOrderFulfillmentItems(), index);
			
			// IMPORTANT & CUSTOM!!!
			// if this was the last item in the fulfillment remove this fulfillment from order
			if(!arrayLen(variables.orderFulfillment.getOrderFulfillmentItems())) {
				variables.order.removeOrderFulfillment(variables.orderFulfillment);
			}
		}
		structDelete(variables, "orderFulfillment");
	}
	
	// Order Return (many-to-one)
	public void function setOrderReturn(required any orderReturn) {
		variables.orderReturn = arguments.orderReturn;
		if(isNew() or !arguments.orderReturn.hasorderReturnItem( this )) {
			arrayAppend(arguments.orderReturn.getorderReturnItems(), this);
		}
	}
	public void function removeOrderReturn(any orderReturn) {
		if(!structKeyExists(arguments, "orderReturn")) {
			arguments.orderReturn = variables.orderReturn;
		}
		var index = arrayFind(arguments.orderReturn.getorderReturnItems(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.orderReturn.getorderReturnItems(), index);
		}
		structDelete(variables, "orderReturn");
	}
	
	// Refrenced Order Item (many-to-one)
	public void function setRefrencedOrderItem(required any refrencedOrderItem) {
		variables.refrencedOrderItem = arguments.refrencedOrderItem;
		if(isNew() or !arguments.refrencedOrderItem.hasRefrencingOrderItems( this )) {
			arrayAppend(arguments.refrencedOrderItem.getRefrencingOrderItem(), this);
		}
	}
	public void function removeRefrencedOrderItem(any refrencedOrderItem) {
		if(!structKeyExists(arguments, "refrencedOrderItem")) {
			arguments.refrencedOrderItem = variables.refrencedOrderItem;
		}
		var index = arrayFind(arguments.refrencedOrderItem.getRefrencingOrderItem(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.refrencedOrderItem.getRefrencingOrderItem(), index);
		}
		structDelete(variables, "refrencedOrderItem");
	}
	
	// Applied Promotions (one-to-many)
	public void function addAppliedPromotion(required any appliedPromotion) {
		arguments.appliedPromotion.setOrderItem( this );
	}
	public void function removeAppliedPromotion(required any appliedPromotion) {
		arguments.appliedPromotion.removeOrderItem( this );
	}
	
	// Applied Taxes (one-to-many)
	public void function addAppliedTax(required any appliedTax) {
		arguments.appliedTax.setOrderItem( this );
	}
	public void function removeAppliedTax(required any appliedTax) {
		arguments.appliedTax.removeOrderItem( this );
	}
	
	// Attribute Values (one-to-many)
	public void function addAttributeValue(required any attributeValue) {
		arguments.attributeValue.setOrderItem( this );
	}
	public void function removeAttributeValue(required any attributeValue) {
		arguments.attributeValue.removeOrderItem( this );
	}
	
	// Order Delivery Items (one-to-many)
	public void function addOrderDeliveryItem(required any orderDeliveryItem) {
		arguments.orderDeliveryItem.setOrderItem( this );
	}
	public void function removeOrderDeliveryItem(required any orderDeliveryItem) {
		arguments.orderDeliveryItem.removeOrderItem( this );
	}
	
	// Stock Receiver Items (one-to-many)
	public void function addStockReceiverItem(required any stockReceiverItem) {
		arguments.stockReceiverItem.setOrderItem( this );
	}
	public void function removeStockReceiverItem(required any stockReceiverItem) {
		arguments.stockReceiverItem.removeOrderItem( this );
	}
	
	// Refrencing Order Items (one-to-many)
	public void function addRefrencingOrderItem(required any refrencingOrderItem) {
		arguments.refrencingOrderItem.setRefrencedOrderItem( this );
	}
	public void function removeRefrencingOrderItem(required any refrencingOrderItem) {
		arguments.refrencingOrderItem.removeRefrencedOrderItem( this );
	}
	
	// =============  END:  Bidirectional Helper Methods ===================
	
	// ============== START: Overridden Implicet Getters ===================
	
	public any function getOrderItemType() {
		if( !structKeyExists(variables, "orderItemType") ) {
			variables.orderItemType = getService("typeService").getTypeBySystemCode("oitSale");
		}
		return variables.orderItemType;
	}
	
	public any function getOrderItemStatusType() {
		if( !structKeyExists(variables, "orderItemStatusType") ) {
			variables.orderItemStatusType = getService("typeService").getTypeBySystemCode("oistNew");
		}
		return variables.orderItemStatusType;
	}
	
	// ==============  END: Overridden Implicet Getters ====================
	
	// ================== START: Overridden Methods ========================
	
	public boolean function isEditable() {
		if(listFindNoCase("ostClosed,ostCanceled", getOrder().getStatusCode())) {
			return false;
		}
		return true;
	} 
	
	public string function getSimpleRepresentation() {
		return getSku().getProduct().getTitle() & " - " & getSku().getSimpleRepresentation(); 
	}
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	public void function preInsert(){
		super.preInsert();
		
		// Verify Defaults are Set
		getOrderItemType();
		getOrderItemStatusType();
		
	}
	
	// ===================  END:  ORM Event Hooks  =========================
}
