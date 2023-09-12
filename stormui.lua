-- for minifier to signal minification
sc = screen

StormUI={}
--[[
    ---Variables---
    t: current ticks
]]
function StormUI.Create(defaultPageBackground)
    --defaultPage={widgets={},background=defaultPageBackground or {type="blank"}}
    local function isInRect(rect, cursor)
        local x, y = cursor[1], cursor[2]
        return cursor[3] and x >= rect.x and x < rect.x + rect.w and y >= rect.y and y < rect.y + rect.w
    end

    local function drawRectF(rect)
        sc.drawRectF(rect.x, rect.y, rect.w, rect.h)
    end

    local function drawRect(rect)
        sc.drawRect(rect.x, rect.y, rect.w, rect.h)
    end

    local function drawTextBox(rect, text, center_x, center_y)
        sc.drawTextBox(rect.x+1, rect.y+1, rect.w, rect.h, text, center_x or 0, center_y or 0)
    end

    local newUI={pages={}, currentPage='default', t=0, theme={}}

    local function get_option(custom_options, name, subtype, default)
        name = name .. (subtype and "_" .. subtype or "")
        return (custom_options and custom_options[name]) or newUI.theme[name] or default
    end

    local function apply_color(custom_options, name, subtype)
        StormUI.utils.setColorToList(get_option(custom_options, name, subtype, {255, 0, 255}))
    end

    function newUI.addPage(id, background)
        --[[
            background types:
            0: blank, dont draw anything
            1: fill; needs argument 'color'
            2: map; needs argument pos={x,y,zoom}
            3: custom; needs an argument 'func' as a callback that takes the page id as an argument
        ]]--
        local page={widgets={},background=background or {type=0}, id=id}
        function page.proccess(cursor, t)
            for k,v in pairs(page.widgets) do
                v.proccess(cursor, t)
            end
        end
        function page.draw()
            local backgroud = page.background
            if background.type==1 then
                StormUI.utils.setColorToList(background.color)
                sc.drawClear()
            elseif background.type==2 then
                sc.drawMap(background.pos[1], background.pos[2], background.pos[3])
            elseif background.type==3 then
                background.func(page.id)
            end
            for k,v in pairs(page.widgets) do
                v.draw()
            end
        end

        --[[
            Supported custom options:
             - outline_color_on
             - outline_color_off
             - fill_color_on
             - fill_color_off
             - label_color_on
             - label_color_off
             - label_on
             - label_off
        ]]
        function page.addToggle(id, x, y, width, height, default, custom_options)
            local toggle={x=x, y=y, w=width, h=height, o=custom_options, active=default, p_click=false, hold_length=0}
            function toggle.proccess(cursor, t)
                pclick=toggle.p_click
                inBounds = isInRect(toggle, cursor)
                toggle.p_click = inBounds
                if cursor[3] then
                    if t==0 then
                        if inBounds and not pclick then
                            active=not active
                            toggle.active=active
                        end
                    end
                    if inBounds then
                        toggle.hold_length=toggle.hold_length+1
                    else
                        toggle.hold_length=0
                    end
                else
                    toggle.hold_length=0
                end
            end
            function toggle.draw()
                local subtype = toggle.active and "on" or "off"
                apply_color(toggle.o, "fill_color", subtype)
                drawRectF(toggle)
                apply_color(toggle.o, "outline_color", subtype)
                drawRect(toggle)
                apply_color(toggle.o, "label_color", subtype)
                drawTextBox(toggle, get_option(toggle.o, "label", subtype, subtype))
            end
            page.widgets[id]=toggle
        end

        --[[
            Supported custom options:
             - outline_color_on
             - outline_color_off
             - fill_color_on
             - fill_color_off
             - label_color_on
             - label_color_off
             - label_on
             - label_off
        ]]
        function page.addPush(id, x, y, width, height, custom_options)
            local push={x=x, y=y, w=width, h=height, o=custom_options, hold_length=0}
            function push.proccess(cursor, t)
                inBounds = isInRect(push, cursor)
                if inBounds then
                    push.hold_length = push.hold_length+1
                else
                    push.hold_length = 0
                end
                push.active = inBounds
            end
            function push.draw()
                local subtype = push.active and "on" or "off"
                apply_color(push.o, "fill_color", subtype)
                drawRectF(push)
                apply_color(push.o, "outline_color", subtype)
                drawRect(push)
                apply_color(push.o, "label_color", subtype)
                drawTextBox(push, get_option(push.o, "label", subtype, subtype))
            end
            page.widgets[id]=push
        end

        --[[
            Supported custom options:
             - outline_color
             - fill_color
             - label_color
             - center_x
             - center_y
        ]]
        function page.addTextbox(id, x, y, width, height, label, custom_options)
            local textbox={x=x, y=y, w=width, h=height, label=label, o=custom_options}
            function textbox.proccess(cursor, t)
            end
            function textbox.draw()
                apply_color(textbox.o, "fill_color")
                drawRectF(textbox)
                apply_color(textbox.o, "outline_color")
                drawRect(textbox)
                apply_color(textbox.o, "label_color")
                drawTextBox(textbox, textbox.label)
            end
            page.widgets[id]=textbox
        end
        function page.addLine(id, x1, y1, x2, y2, color)
            local line={x1=x1,y1=y1,x2=x2, y2=y2, color=color}
            function line.proccess(cursor, t)
            end
            function line.draw()
                StormUI.utils.setColorToList(line.color)
                sc.drawLine(line.x1, line.y1, line.x2, line.y2)
            end
            page.widgets[id]=line
        end

        --[[
            Supported custom options:
             - outline_color
             - fill_color
        ]]
        function page.addRect(id, x, y, width, height, custom_options)
            local rect={x=x, y=y, w=width, h=height, o=custom_options}
            function rect.proccess(cursor, t)
            end
            function rect.draw()
                apply_color(rect.o, "fill_color")
                drawRectF(rect)
                apply_color(rect.o, "outline_color")
                drawRect(rect)
            end
            page.widgets[id]=rect
        end

        --[[
            Supported custom options:
             - outline_color
             - fill_color_on
             - fill_color_off
        ]]
        function page.addIndicatorRect(id, x, y, width, height, custom_options)
            local rectIndic={x=x, y=y, w=width, h=height, o=custom_options, active=false}
            function rectIndic.proccess(cursor, t)
            end
            function rectIndic.draw()
                apply_color(rectIndic.o, "fill_color", rectIndic.active and "on" or "off")
                drawRectF(rectIndic)
                apply_color(rectIndic.o, "outline_color")
                drawRect(rectIndic)
            end
            page.widgets[id]=rectIndic
        end

        --[[
            Supported custom options:
             - outline_color
             - fill_color_on
             - fill_color_off
        ]]
        function page.addIndicatorCircle(id, x, y, radius, custom_options)
            local circIndic={x=x,y=y, r=radius, o=custom_options, active=false}
            function circIndic.proccess(cursor, t)
            end
            function circIndic.draw()
                apply_color(circIndic.o, "fill_color", rectIndic.active and "on" or "off")
                sc.drawCircleF(circIndic.x, circIndic.y, circIndic.r)
                apply_color(circIndic.o, "outline_color")
                sc.drawCircle(circIndic.x, circIndic.y, circIndic.r)
            end
            page.widgets[id]=circIndic
        end
        newUI.pages[id]=page
    end
    function newUI.setPage(id)
        if newUI.pages[id] then
            newUI.currentPage=id
        end
    end
    function newUI.process(cursor)
        newUI.pages[newUI.currentPage].proccess(cursor, newUI.t)
        if cursor[3] then
            newUI.t=newUI.t+1
        else
            newUI.t=0
        end
    end
    function newUI.draw()
        newUI.pages[newUI.currentPage].draw()
    end
    function newUI.getPage()
        return newUI.pages[newUI.currentPage]
    end
    newUI.addPage('default', defaultPageBackground or {type="blank"})
    return newUI
end

StormUI.utils={
    setColorToList=function(list)
        sc.setColor(list[1],list[2],list[3],list[4])
    end
}

StormUI.colors={
    Transparent={0,0,0,0}
    White={255,255,255,255}
    Black={0,0,0,255}
}
