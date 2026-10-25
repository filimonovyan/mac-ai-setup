import {registerRoot, Composition, AbsoluteFill, useCurrentFrame} from 'remotion';
const Hello = () => <AbsoluteFill style={{background:'white',justifyContent:'center',alignItems:'center',fontSize:80}}>Привет {useCurrentFrame()}</AbsoluteFill>;
const Root = () => <Composition id="Hello" component={Hello} durationInFrames={30} fps={30} width={640} height={360}/>;
registerRoot(Root);
