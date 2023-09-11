StormUI={}
function StormUI.Create(defaultPageBackground)
    --defaultPage={widgets={},background=defaultPageBackground or {type="blank"}}
    
    local newUI={pages={}, currentPage='default', cticks=0}
    function newUI.addPage(id, background)
        --[[
            background types:
            0: blank, dont draw anything
            1: fill; needs argument 'color'
            2: map; needs argument pos={x,y,zoom}
            3: custom; needs an argument 'func' as a callback that takes the page id as an argument
        ]]--
        local background=background or {type=0}
        local page={widgets={},background=background, id=id}
        function page.proccess(cursor, cticks)
            for k,v in pairs(page.widgets) do
                v.proccess(cursor, cticks)
            end
        end
        function page.draw()
            if page.background.type==1 then
                StormUI.utils.setColorToList(page.background.color)
                screen.drawRectF(0,0,screen.getWidth()+1, screen.getHeight()+1)
            elseif page.background.type==2 then
                screen.drawMap(page.background.pos[1], page.background.pos[2], page.background.pos[3])
            elseif page.background.type==3 then
                page.background.func(page.id)
            end
            for k,v in pairs(page.widgets) do
                v.draw()
            end
        end
        function page.addToggle(id, x, y, width, height, outline_color_on, outline_color_off, fill_color_on, fill_color_off, label_off, label_on, label_color_on, label_color_off, default)
            local toggle={x=x,y=y,width=width, height=height, outline_color_on=outline_color_on, outline_color_off=outline_color_off, fill_color_on=fill_color_on, fill_color_off=fill_color_off, label_off=label_off, label_on=label_on, label_color_off=label_color_off, label_color_on=label_color_on, active=default, p_click=false, hold_length=0}
            function toggle.proccess(cursor, cticks)
                cursorx=cursor[1]
                cursory=cursor[2]
                x1=toggle.x
                x2=toggle.width+x1
                y1=toggle.y
                y2=toggle.height+y1
                pclick=toggle.p_click
                inBounds=(cursorx>x1 and cursorx<x2 and cursory>y1 and cursory<y2)
                toggle.p_click=inBounds and cursor[3]
                if cursor[3] then
                    if cticks==0 then
                        toggled=toggle.active
                        if inBounds and not pclick then
                            active=not active
                            toggle.active=active
                        end
                    end
                    toggle.hold_length=toggle.hold_length+1
                else
                    toggle.hold_length=0
                end
            end
            function toggle.draw()
                if toggle.active then
                    StormUI.utils.setColorToList(toggle.fill_color_on)
                    screen.drawRectF(toggle.x, toggle.y, toggle.width, toggle.height)
                    StormUI.utils.setColorToList(toggle.outline_color_on)
                    screen.drawRect(toggle.x, toggle.y, toggle.width, toggle.height)
                    StormUI.utils.setColorToList(toggle.label_color_on)
                    screen.drawTextBox(toggle.x+1, toggle.y+1, toggle.width, toggle.height, toggle.label_on, 0, 0)
                else
                    StormUI.utils.setColorToList(toggle.fill_color_off)
                    screen.drawRectF(toggle.x, toggle.y, toggle.width, toggle.height)
                    StormUI.utils.setColorToList(toggle.outline_color_off)
                    screen.drawRect(toggle.x, toggle.y, toggle.width, toggle.height)
                    StormUI.utils.setColorToList(toggle.label_color_off)
                    screen.drawTextBox(toggle.x+1, toggle.y+1, toggle.width, toggle.height, toggle.label_off, 0, 0)
                end
            end
            page.widgets[id]=toggle
        end
        function page.addPush(id, x, y, width, height, outline_color_on, outline_color_off, fill_color_on, fill_color_off, label_off, label_on, label_color_on, label_color_off)
            local push={x=x,y=y,width=width, height=height, outline_color_on=outline_color_on, outline_color_off=outline_color_off, fill_color_on=fill_color_on, fill_color_off=fill_color_off, label_off=label_off, label_on=label_on, label_color_off=label_color_off, label_color_on=label_color_on, hold_length=0}
            function push.proccess(cursor, cticks)
                cursorx=cursor[1]
                cursory=cursor[2]
                x1=push.x
                x2=push.width+x1
                y1=push.y
                y2=push.height+y1
                inBounds=(cursorx>x1 and cursorx<x2 and cursory>y1 and cursory<y2)
                if cursor[3] then
                    push.hold_length=push.hold_length+1
                else
                    push.hold_length=0
                end
                push.active=inBounds and cursor[3]
            end
            function push.draw()
                if push.active then
                    StormUI.utils.setColorToList(push.fill_color_on)
                    screen.drawRectF(push.x, push.y, push.width, push.height)
                    StormUI.utils.setColorToList(push.outline_color_on)
                    screen.drawRect(push.x, push.y, push.width, push.height)
                    StormUI.utils.setColorToList(push.label_color_on)
                    screen.drawTextBox(push.x+1, push.y+1, push.width, push.height, push.label_on, 0, 0)
                else
                    StormUI.utils.setColorToList(push.fill_color_off)
                    screen.drawRectF(push.x, push.y, push.width, push.height)
                    StormUI.utils.setColorToList(push.outline_color_off)
                    screen.drawRect(push.x, push.y, push.width, push.height)
                    StormUI.utils.setColorToList(push.label_color_off)
                    screen.drawTextBox(push.x+1, push.y+1, push.width, push.height, push.label_off, 0, 0)
                end
            end
            page.widgets[id]=push
        end
        function page.addTextbox(id, x, y, width, height, outline_color, fill_color, label, label_color, center_x, center_y)
            local textbox={x=x,y=y,width=width, height=height, outline_color=outline_color, fill_color=fill_color, label=label, label_color=label_color, center_x=center_x, center_y=center_y}
            function textbox.proccess(cursor, cticks)
            end
            function textbox.draw()
                StormUI.utils.setColorToList(textbox.fill_color)
                screen.drawRectF(textbox.x, textbox.y, textbox.width, textbox.height)
                StormUI.utils.setColorToList(textbox.outline_color)
                screen.drawRect(textbox.x, textbox.y, textbox.width, textbox.height)
                StormUI.utils.setColorToList(textbox.label_color)
                screen.drawTextBox(textbox.x+1, textbox.y+1, textbox.width, textbox.height, textbox.label, textbox.center_x, textbox.center_y)
            end
            page.widgets[id]=textbox
        end
        function page.addLine(id, x1, y1, x2, y2, color)
            local line={x1=x1,y1=y1,x2=x2, y2=y2, color=color}
            function line.proccess(cursor, cticks)
            end
            function line.draw()
                StormUI.utils.setColorToList(line.color)
                screen.drawLine(line.x1, line.y1, line.x2, line.y2)
            end
            page.widgets[id]=line
        end
        function page.addRect(id, x, y, width, height, border_color, fill_color)
            local rect={x=x,y=y, width=width, height=height, border_color=border_color, fill_color=fill_color}
            function rect.proccess(cursor, cticks)
            end
            function rect.draw()
                StormUI.utils.setColorToList(rect.fill_color)
                screen.drawRectF(rect.x, rect.y, rect.width, rect.height)
                StormUI.utils.setColorToList(rect.border_color)
                screen.drawRect(rect.x, rect.y, rect.width, rect.height)
            end
            page.widgets[id]=rect
        end
        function page.addIndicatorRect(id, x, y, width, height, border_color, fill_color_on, fill_color_off)
            local rectIndic={x=x,y=y, width=width, height=height, border_color=border_color, fill_color_on=fill_color_on, fill_color_off=fill_color_off, active=false}
            function rectIndic.proccess(cursor, cticks)
            end
            function rectIndic.draw()
                if rectIndic.active then
                    StormUI.utils.setColorToList(rectIndic.fill_color_on)
                else
                    StormUI.utils.setColorToList(rectIndic.fill_color_off)
                end
                screen.drawRectF(rectIndic.x, rectIndic.y, rectIndic.width, rectIndic.height)
                StormUI.utils.setColorToList(rectIndic.border_color)
                screen.drawRect(rectIndic.x, rectIndic.y, rectIndic.width, rectIndic.height)
            end
            page.widgets[id]=rectIndic
        end
        function page.addIndicatorCircle(id, x, y, radius, border_color, fill_color_on, fill_color_off)
            local circIndic={x=x,y=y, radius=radius, border_color=border_color, fill_color_on=fill_color_on, fill_color_off=fill_color_off, active=false}
            function circIndic.proccess(cursor, cticks)
            end
            function circIndic.draw()
                if circIndic.active then
                    StormUI.utils.setColorToList(circIndic.fill_color_on)
                else
                    StormUI.utils.setColorToList(circIndic.fill_color_off)
                end
                screen.drawCircleF(circIndic.x, circIndic.y, circIndic.radius)
                StormUI.utils.setColorToList(circIndic.border_color)
                screen.drawCircle(circIndic.x, circIndic.y, circIndic.radius)
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
        newUI.pages[newUI.currentPage].proccess(cursor, newUI.cticks)
        if cursor[3] then
            newUI.cticks=newUI.cticks+1
        else
            newUI.cticks=0
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
StormUI.utils={}

function StormUI.utils.setColorToList(list)
    r=list[1]
    g=list[2]
    b=list[3]
    a=list[4]
    screen.setColor(r,g,b,a)
end

StormUI.colors={}

StormUI.colors.Transparent={0,0,0,0}
StormUI.colors.White={255,255,255,255}
StormUI.colors.Black={0,0,0,255}
