<!---

    Slatwall - An e-commerce plugin for Mura CMS
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

--->
<cfparam name="rc.messages" type="array" default="#arrayNew(1)#" />

<cfoutput>
	<div class="span10">
		<cfloop array="#rc.messages#" index="local.message">
			<div class="alert alert-#local.message.messageType#">
				<a class="close" data-dismiss="alert">x</a>
				#local.message.message#
			</div>
		</cfloop>
		#body#
	</div>
	<div class="span2">
		<div class="well" style="padding:8px 0;">
			<ul class="nav nav-list">
				<li class="nav-header">#rc.$.slatwall.rbKey('admin.product')#</li>
				<cf_SlatwallActionCaller action="admin:product.listproducts" type="list">
				<cf_SlatwallActionCaller action="admin:product.createproduct" type="list">
				<li class="divider"></li>
				<cf_SlatwallActionCaller action="admin:product.listproducttypes" type="list">
				<cf_SlatwallActionCaller action="admin:product.createproducttype" type="list">
				<li class="divider"></li>
				<cf_SlatwallActionCaller action="admin:product.listoptiongroups" type="list">
				<cf_SlatwallActionCaller action="admin:product.createoptiongroup" type="list">
				<li class="divider"></li>
				<cf_SlatwallActionCaller action="admin:product.createbrand" type="list">
				<cf_SlatwallActionCaller action="admin:product.listbrands" type="list">
			</ul>
		</div>
	</div>
</cfoutput>