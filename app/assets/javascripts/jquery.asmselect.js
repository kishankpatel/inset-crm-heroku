/*
 * Alternate Select Multiple (asmSelect) 1.0.6 beta - jQuery Plugin
 * http://www.ryancramer.com/projects/asmselect/ (Origin)
 * 
 * Copyright (c) 2009 by Ryan Cramer
 * Copyright (C) 2015 by Nerijus Barauskas
 * Copyright (C) 2016 by Insightly
 * 
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 */

(function($) {

    $.fn.asmSelect = function(customOptions) {

        var options = {

            listType: 'ol',                            // Ordered list 'ol', or unordered list 'ul'
            sortable: false,                           // Should the list be sortable?
            highlight: false,                          // Use the highlight feature? 
            animate: false,                            // Animate the the adding/removing of items in the list?
            addItemTarget: 'bottom',                   // Where to place new selected items in list: top or bottom
            hideWhenAdded: false,                      // Hide the option when added to the list? works only in FF
            debugMode: false,                          // Debug mode keeps original select visible 

            removeLabel: 'remove',                     // Text used in the "remove" link
            highlightAddedLabel: 'Added: ',            // Text that precedes highlight of added item
            highlightRemovedLabel: 'Removed: ',        // Text that precedes highlight of removed item

            containerClass: 'asmContainer',            // Class for container that wraps this widget
            selectClass: 'asmSelect',                  // Class for the newly created <select>
            optionDisabledClass: 'asmOptionDisabled',  // Class for items that are already selected / disabled
            listClass: 'asmList',                      // Class for the list ($ol)
            listSortableClass: 'asmListSortable',      // Another class given to the list when it is sortable
            listItemClass: 'asmListItem',              // Class for the <li> list items
            listItemLabelClass: 'asmListItemLabel',    // Class for the label text that appears in list items
            removeClass: 'asmListItemRemove',          // Class given to the "remove" link
            highlightClass: 'asmHighlight',            // Class given to the highlight <span>

            // Insightly add-ons
            itemOrder: null,                            // Specifies the order of the items. This should be an array of the item value. 
                                                        // The order of the array dictates the order of the item.
            requiredItems: null,                        // Specifies the items that are required. Required item will not have the "remove" button.
                                                        // Required items should be marked as selected in the source select list.
            addCallback: null,
            dropCallback: null,
            moveCallback: null,
        };

        $.extend(options, customOptions); 

        return this.each(function(index) {

            var $original = $(this);                 // the original select multiple
            var $container;                          // a container that is wrapped around our widget
            var $select;                             // the new select we have created
            var $ol;                                 // the list that we are manipulating
            var buildingSelect = false;              // is the new select being constructed right now?
            var ieClick = false;                     // in IE, has a click event occurred? ignore if not
            var ignoreOriginalChangeEvent = false;   // originalChangeEvent bypassed when this is true

            function init() {

                // initialize the alternate select multiple

                // this loop ensures uniqueness, in case of existing asmSelects placed by ajax (1.0.3)
                while($("#" + options.containerClass + index).size() > 0) index++; 

                $select = $("<select></select>")
                    .addClass(options.selectClass)
                    .attr('name', options.selectClass.replace(/\s/g, "-") + index)
                    .attr('id', options.selectClass.replace(/\s/g, "-") + index); 

                $selectRemoved = $("<select></select>"); 

                $ol = $("<" + options.listType + "></" + options.listType + ">")
                    .addClass(options.listClass)
                    .attr('id', options.listClass + index); 

                $container = $("<div></div>")
                    .addClass(options.containerClass) 
                    .attr('id', options.containerClass + index); 

                buildSelect();

                $select.change(selectChangeEvent)
                    .click(selectClickEvent); 

                $original.change(originalChangeEvent)
                    .wrap($container).before($select).before($ol);

                if(options.sortable) makeSortable();

                order();

                if($.browser.msie && $.browser.version < 8) $ol.css('display', 'inline-block'); // Thanks Matthew Hutton

                //Applying select if chosen class is set.
                if( $select.hasClass( 'chosen' ) ) {
                    if( $select.is( ":visible" ) )
                        $select.chosen();
                    else
                        $select.chosen({width: "100\%"});
                }
            }

            function makeSortable() {

                // make any items in the selected list sortable
                // requires jQuery UI sortables, draggables, droppables

                $ol.sortable({
                    items: 'li.' + options.listItemClass,
                    handle: '.' + options.listItemLabelClass,
                    axis: 'y',
                    update: function(e, data) {

                        var updatedOptionId;

                        $(this).children("li").each(function(n) {

                            $option = $('#' + $(this).attr('rel')); 

                            if($(this).is(".ui-sortable-helper")) {
                                updatedOptionId = $option.attr('id'); 
                                return;
                            }

                            $original.append($option); 
                        }); 

                        if (updatedOptionId) triggerOriginalChange(updatedOptionId, 'sort');

                        if (options.moveCallback) {
                            options.moveCallback();
                        }
                    }

                }).addClass(options.listSortableClass); 
            }

            function selectChangeEvent(e) {
                
                // an item has been selected on the regular select we created
                // check to make sure it's not an IE screwup, and add it to the list

                if($.browser.msie && $.browser.version < 7 && !ieClick) return;
                var id = $(this).children("option:selected").slice(0,1).attr('rel');
                if( id == undefined )
                    id = $(this).children("optgroup").children("option:selected").slice(0,1).attr('rel'); 
                if(id) { 
                    // thanks to petersumskas and eliel_goco@yahoo.com
                    addListItem(id);
                    ieClick = false; 
                    triggerOriginalChange(id, 'add'); // for use by user-defined callbacks
                    if (options.addCallback) {
                        options.addCallback();
                    }
                }
            }

            function selectClickEvent() {

                // IE6 lets you scroll around in a select without it being pulled down
                // making sure a click preceded the change() event reduces the chance
                // if unintended items being added. there may be a better solution?

                ieClick = true; 
            }

            function originalChangeEvent(e) {

                // select or option change event manually triggered
                // on the original <select multiple>, so rebuild ours

                if(ignoreOriginalChangeEvent) {
                    ignoreOriginalChangeEvent = false; 
                    return; 
                }
		
                $select.empty();
                $ol.empty();
                buildSelect();
                if( $(this).siblings( "select" ).hasClass( "chosen" ) )
                    $(this).siblings( "select" ).trigger( "chosen:updated" );

                // opera has an issue where it needs a force redraw, otherwise
                // the items won't appear until something else forces a redraw
                if($.browser.opera) $ol.hide().fadeIn("fast");
            }

            function buildSelect() {

                // build or rebuild the new select that the user
                // will select items from

                buildingSelect = true; 

                // add a first option to be the home option / default selectLabel
                if( $original.attr( 'title' ) )
                     $select.prepend("<option value=''>" + $original.attr('title') + "</option>"); 

                var cnt = 0;
                var cnt1 = 0;
                var group = null;
                var select = null;
                var idOrders = [];

                if( $original.children( "option" ).length > 0 ) {
                    $original.children("option").each(function(n) {
                        
			var $t = $(this); 
                        var id; 
                        var isSelected = $t.is(":selected"); 
                        var isDisabled = $t.is(":disabled"); 

                        if(!$t.attr('id'))
                            $t.attr('id', 'asm' + index + 'option' + cnt++); 
                        else
                            cnt++;

                        id = $t.attr('id'); 
    
                        if(isSelected && !isDisabled) { 
                            if (options.itemOrder === null) {
                                addListItem(id);
                            } else {
                                idOrders[$t.val()] = id;
                            }
                            addSelectOption(id, true);                         

                        } else if(!isSelected && isDisabled) {
                            addSelectOption(id, true); 

                        } else {
                            addSelectOption(id); 
                        }
                    });
                }

                if (options.itemOrder !== null) {
                    options.itemOrder.forEach(function (v) {
                        var id = idOrders[v];
                        addListItem(id);
                    });
                }

                if( $original.children( "optgroup" ).length > 0 ) {
                    $original.children("optgroup").each(function(m) {
                        group = addSelectOptgroup( 'asm' + index + 'optgroup' + cnt1, $( this ).attr( "label" ) );
                        select = $select;
                        $select = group;
                        $( this ).children("option").each(function(n) {

                            var $t = $(this);
                            var id;
                            var isSelected = $t.is(":selected"); 
                            var isDisabled = $t.is(":disabled"); 
  
                            if(!$t.attr('id')) $t.attr('id', 'asm' + index + 'option' + cnt++);
                            id = $t.attr('id');
        
                            if(isSelected && !isDisabled) { 
                                addListItem(id); 
                                addSelectOption(id, true);                         

                            } else if(!isSelected && isDisabled) {
                                addSelectOption(id, true); 

                            } else {
                                addSelectOption(id); 
                            }
                            $t.text( group.attr("label") + ": " + $t.text() );
                         
                        });
                        $select = select;
                        cnt1++;
                    });
                }

                if(!options.debugMode) $original.hide(); // IE6 requires this on every buildSelect()
                selectFirstItem();
                buildingSelect = false; 
            }

            function addSelectOption(optionId, disabled) {

                // add an <option> to the <select>
                // used only by buildSelect()

                if(disabled == undefined) var disabled = false; 

                var $O = $('#' + optionId); 
                var $option = $("<option>" + $O.html() + "</option>")
                    .val($O.val())
                    .attr('rel', optionId);

                if(disabled) disableSelectOption($option); 

                $select.append($option); 
            }

            function addSelectOptgroup(id, label) {

                // add an <optgroup> to the <select>
                // used only by buildSelect()

                var group = $( '<optgroup id="' + id + '" label="' + label + '"></optgroup>' );
                $select.append(group);
                return group;
            }

            function selectFirstItem() {

                // select the firm item from the regular select that we created

                if( $select.children(":eq(0)") )
                    $select.children(":eq(0)").attr("selected", true); 
                else if( $select.children().children(":eq(0)") )
                    $select.children().children(":eq(0)").attr("selected", true);
            }

            function disableSelectOption($option) {

                // make an option disabled, indicating that it's already been selected
                // because safari is the only browser that makes disabled items look 'disabled'
                // we apply a class that reproduces the disabled look in other browsers

                $option.addClass(options.optionDisabledClass).
                    removeAttr("selected")
                    .attr("disabled", true);

                if(options.hideWhenAdded) $option.hide();
                if($.browser.msie) $select.hide().show(); // this forces IE to update display
                if( $option.closest( "select" ).hasClass( "chosen" ) )
                    $option.closest( "select" ).trigger( "chosen:updated" );
            }

            function enableSelectOption($option) {

                // given an already disabled select option, enable it

                $option.removeClass(options.optionDisabledClass)
                    .removeAttr("disabled"); 

                if(options.hideWhenAdded) $option.show();
                if($.browser.msie) $select.hide().show(); // this forces IE to update display
                if( $option.closest( "select" ).hasClass( "chosen" ) )
                    $option.closest( "select" ).trigger( "chosen:updated" );
            }

            function addListItem(optionId) {

                // add a new item to the html list
                var $O = $('#' + optionId); 

                if(!$O) return; // this is the first item, selectLabel

                var $removeLink = $("<a></a>")
                    .attr("href", "#")
                    .addClass(options.removeClass)
                    .prepend(options.removeLabel)
                    .click(function() { 
                        dropListItem($(this).parent('li').attr('rel')); 
                        return false; 
                    }); 
                
                var label = $O.html();
                if( $O.parent().is('optgroup') ) {
                    if( label.indexOf( $O.parent().attr( "label" ) ) != 0 )
                        label = $O.parent().attr( "label" ) + ": " + label; 
                }

                var $itemLabel = $("<span></span>")
                    .addClass(options.listItemLabelClass)
                    .html(label); 

                var $item = $("<li></li>")
                    .attr('rel', optionId)
                    .addClass(options.listItemClass)
                    .append($itemLabel);

                if ($.inArray($O.val(), options.requiredItems) === -1) {
                    $item.append($removeLink);
                };
                    
                $item.hide();

                if(!buildingSelect) {
                    if($O.is(":selected")) return; // already have it
                    $O.attr('selected', true); 
                }

                if(options.addItemTarget == 'top' && !buildingSelect) {
                    $ol.prepend($item); 
                    if(options.sortable) $original.prepend($O); 
                } else {
                    $ol.append($item); 
                    if(options.sortable) $original.append($O); 
                }

                addListItemShow($item); 

                disableSelectOption($("[rel=" + optionId + "]", $select));

                if(!buildingSelect) {
                    setHighlight($item, options.highlightAddedLabel); 
                    selectFirstItem();
                    if(options.sortable) $ol.sortable("refresh");     
                }

            }

            function addListItemShow($item) {

                // reveal the currently hidden item with optional animation
                // used only by addListItem()

                if(options.animate && !buildingSelect) {
                    $item.animate({
                        opacity: "show",
                        height: "show"
                    }, 100, "swing", function() { 
                        $item.animate({
                            height: "+=2px"
                        }, 50, "swing", function() {
                            $item.animate({
                                height: "-=2px"
                            }, 25, "swing"); 
                        }); 
                    }); 
                } else {
                    $item.show();
                }
            }

            function dropListItem(optionId, highlightItem) {

                // remove an item from the html list

                if(highlightItem == undefined) var highlightItem = true; 
                var $O = $('#' + optionId); 

                $O.removeAttr('selected'); 
                $item = $ol.children("li[rel=" + optionId + "]");

                dropListItemHide($item); 
                enableSelectOption($("[rel=" + optionId + "]", options.removeWhenAdded ? $selectRemoved : $select));

                if(highlightItem) setHighlight($item, options.highlightRemovedLabel); 

                triggerOriginalChange(optionId, 'drop');
                if (options.dropCallback) options.dropCallback();
            }

            function dropListItemHide($item) {

                // remove the currently visible item with optional animation
                // used only by dropListItem()

                if(options.animate && !buildingSelect) {

                    $prevItem = $item.prev("li");

                    $item.animate({
                        opacity: "hide",
                        height: "hide"
                    }, 100, "linear", function() {
                        $prevItem.animate({
                            height: "-=2px"
                        }, 50, "swing", function() {
                            $prevItem.animate({
                                height: "+=2px"
                            }, 100, "swing"); 
                        }); 
                        $item.remove(); 
                    }); 
                    
                } else {
                    $item.remove(); 
                }
            }

            function setHighlight($item, label) {

                // set the contents of the highlight area that appears
                // directly after the <select> single
                // fade it in quickly, then fade it out

                if(!options.highlight) return; 

                $select.next("#" + options.highlightClass + index).remove();

                var $highlight = $("<span></span>")
                    .hide()
                    .addClass(options.highlightClass)
                    .attr('id', options.highlightClass + index)
                    .html(label + $item.children("." + options.listItemLabelClass).slice(0,1).text()); 
                    
                $select.after($highlight); 

                $highlight.fadeIn("fast", function() {
                    setTimeout(function() { $highlight.fadeOut("slow"); }, 50); 
                }); 
            }

            function triggerOriginalChange(optionId, type) {

                // trigger a change event on the original select multiple
                // so that other scripts can pick them up

                ignoreOriginalChangeEvent = true; 
                $option = $("#" + optionId); 

                $original.trigger('change', [{
                    'option': $option,
                    'value': $option.val(),
                    'id': optionId,
                    'item': $ol.children("[rel=" + optionId + "]"),
                    'type': type
                }]); 

            }

            function order(){
                if( !$original.attr( 'data-order' ) || typeof $original.attr( 'data-order' ) === "undefined" ) return;

		var delimiter = typeof $original.attr( 'data-order-delimiter' ) !== "undefined" ? $original.attr( 'data-order-delimiter' ) : ',';
                var order = $original.attr( 'data-order' ).split( delimiter );
                if( !order ) return;

                var items = Object();
                $original.siblings( "select" ).each( function() {
                    $( this ).children( "option" ).each( function(){
                        if( $.inArray( $( this ).attr( "value" ), order ) != -1 )
                            items[$( this ).attr( "value" )] = $( this ).attr( "rel" );
                    });
                    $( this ).children( "optgroup" ).each( function(){
                        $( this ).children( "option" ).each( function(){
                            if( $.inArray( $( this ).attr( "value" ), order ) != -1 )
                                items[$( this ).attr( "value" )] = $( this ).attr( "rel" );
                        });
                    });
                });

                $original.siblings( "ol" ).each( function() {
                    $( this ).children( "li" ).each( function() {
                        var item = $( this );
                        $.each( items, function( key, value ) {
                            if( item.attr( "rel" ) == value )
                                items[key] = item;
                        });
                    });

                    $( this ).html("");
                    var ol = $( this );
                    $.each( order, function( key, value ){
                        if( items[value] != undefined ){
                            ol.append( items[value] );
                            items[value].children( "." + options.removeClass ).click( function(){
                                dropListItem( items[value].attr( "rel" ) );
                                return false; 
                            });
                        }
                    });
                });

                $.each( order, function( key, value ){
                    var tmp = $original.children( 'option[value="' + value + '"]' );
                    $original.append( $original.children( 'option[value="' + value + '"]' ) );
                });
            }

            init();
        });
    };

})(jQuery); 