sub Init()
    m.background=m.top.FindNode("background") : m.title=m.top.FindNode("title") : m.subtitle=m.top.FindNode("subtitle") : m.statusLabel=m.top.FindNode("statusLabel") : m.seasonsGroup=m.top.FindNode("seasonsGroup") : m.hintLabel=m.top.FindNode("hintLabel")
    m.seasons=[] : m.itemNodes=[] : m.selectedIndex=0 : m.firstVisibleIndex=0
    configureLayout()
end sub

sub configureLayout()
    size=CreateObject("roDeviceInfo").GetDisplaySize() : w=size.w : h=size.h
    m.margin=80 : if h<=720 then m.margin=48
    m.cardW=112 : m.cardH=78 : m.gap=34 : if h<=720 then m.cardW=92 : m.cardH=62 : m.gap=24
    m.contentW=w-(m.margin*2) : m.columns=Int((m.contentW+m.gap)/(m.cardW+m.gap)) : if m.columns<1 then m.columns=1
    m.rows=2 : m.visibleItemCount=m.columns*m.rows
    m.background.width=w : m.background.height=h
    m.title.width=w : m.title.translation=[0,86] : m.title.font="font:LargeBoldSystemFont" : m.title.text="TEMPORADAS"
    m.subtitle.width=w : m.subtitle.translation=[0,144] : m.subtitle.font="font:MediumSystemFont"
    m.seasonsGroup.translation=[m.margin,250]
    if h<=720 then m.title.translation=[0,48] : m.subtitle.translation=[0,96] : m.seasonsGroup.translation=[m.margin,178]
    m.statusLabel.width=m.contentW : m.statusLabel.translation=[m.margin, m.seasonsGroup.translation[1]+120] : m.statusLabel.font="font:MediumSystemFont"
    m.hintLabel.width=w : m.hintLabel.translation=[0,h-36] : m.hintLabel.font="font:SmallSystemFont"
end sub

sub show(series as Dynamic)
    configureLayout() : m.subtitle.text=getName(series) : resetSelection() : renderList() : updateFocus() : m.top.visible=true : m.top.SetFocus(true)
end sub
sub hide() : m.top.visible=false : end sub
sub resetSelection() : m.selectedIndex=0 : m.firstVisibleIndex=0 : end sub
sub setLoading(isLoading as Boolean) : clearSeasonNodes() : if isLoading then m.statusLabel.text="Carregando temporadas..." else m.statusLabel.text="" : end sub
sub setSeasons(seasons as Object)
    if seasons<>invalid and Type(seasons)="roArray" then m.seasons=seasons else m.seasons=[]
    resetSelection() : if m.seasons.Count()=0 then showMessage("Temporadas indisponíveis.") : return
    m.statusLabel.text="" : renderList() : updateFocus()
end sub
sub showMessage(message as String) : clearSeasonNodes() : m.seasons=[] : m.statusLabel.color="#FFCC66" : m.statusLabel.text=message : end sub

sub renderList()
    clearSeasonNodes() : if m.seasons.Count()=0 then return
    last=m.firstVisibleIndex+m.visibleItemCount-1 : if last>=m.seasons.Count() then last=m.seasons.Count()-1
    for i=m.firstVisibleIndex to last
        v=i-m.firstVisibleIndex : col=v mod m.columns : row=Int(v/m.columns)
        g=CreateObject("roSGNode","Group") : g.translation=[col*(m.cardW+m.gap), row*(m.cardH+m.gap)]
        bg=CreateObject("roSGNode","Rectangle") : bg.id="itemBackground" : bg.width=m.cardW : bg.height=m.cardH : bg.color="#111827" : bg.opacity=.95
        lb=CreateObject("roSGNode","Label") : lb.id="itemLabel" : lb.width=m.cardW : lb.height=m.cardH : lb.horizAlign="center" : lb.vertAlign="center" : lb.font="font:MediumBoldSystemFont" : lb.color="#FFFFFF" : lb.text=getSeasonNumberText(m.seasons[i])
        g.AppendChild(bg) : g.AppendChild(lb) : m.seasonsGroup.AppendChild(g) : m.itemNodes.Push(g)
    end for
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key="back" or key="left" then m.top.backRequested=true : return true
    if key="right" then moveFocus(1) : return true
    if key="up" then moveFocus(-m.columns) : return true
    if key="down" then moveFocus(m.columns) : return true
    if key="OK" then
        if m.seasons.Count()>0 then m.top.seasonSelected=m.seasons[m.selectedIndex]
        return true
    end if
    return false
end function
sub moveFocus(delta as Integer)
    if m.seasons.Count()=0 then return
    oldFirst=m.firstVisibleIndex : m.selectedIndex=m.selectedIndex+delta
    if m.selectedIndex<0 then m.selectedIndex=0
    if m.selectedIndex>=m.seasons.Count() then m.selectedIndex=m.seasons.Count()-1
    if m.selectedIndex<m.firstVisibleIndex then m.firstVisibleIndex=m.selectedIndex
    if m.selectedIndex>=m.firstVisibleIndex+m.visibleItemCount then m.firstVisibleIndex=m.selectedIndex-m.visibleItemCount+1
    if oldFirst<>m.firstVisibleIndex then renderList()
    updateFocus()
end sub
sub updateFocus()
    for i=0 to m.itemNodes.Count()-1
        real=m.firstVisibleIndex+i : bg=m.itemNodes[i].FindNode("itemBackground")
        if real=m.selectedIndex then bg.color="#0B3A5E" : m.itemNodes[i].scale=[1.08,1.08] else bg.color="#111827" : m.itemNodes[i].scale=[1,1]
    end for
end sub
sub clearSeasonNodes() : while m.seasonsGroup.GetChildCount()>0 : m.seasonsGroup.RemoveChildIndex(0) : end while : m.itemNodes=[] : end sub
function getSeasonNumberText(season as Dynamic) as String
    if season <> invalid and Type(season) = "roAssociativeArray" then
        if season.DoesExist("season_number") and season.season_number <> invalid and season.season_number.ToStr().Trim() <> "" then return season.season_number.ToStr()
        if season.DoesExist("name") and season.name <> invalid and season.name.ToStr().Trim() <> "" then return season.name.ToStr()
    end if
    return "?"
end function

function getName(item as Dynamic) as String
    if item <> invalid and Type(item) = "roAssociativeArray" then
        if item.DoesExist("name") and item.name <> invalid then return item.name.ToStr()
        if item.DoesExist("title") and item.title <> invalid then return item.title.ToStr()
    end if
    return ""
end function
