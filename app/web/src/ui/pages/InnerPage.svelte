<script>
    import RouteState from "../state/RouteState";
</script>

<div>
    <h1>Inner Page</h1>
    
    <button on:click={()=>{RouteState.navigate("/inner/child")}} >Child</button>
    <button on:click={()=>{RouteState.navigate("/")}} >Back</button>
</div>
