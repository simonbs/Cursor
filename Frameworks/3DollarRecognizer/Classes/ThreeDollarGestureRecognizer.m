//
//  ThreeDollarGestureRecognizer.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 30.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import "ThreeDollarGestureRecognizer.h"
#import <math.h>

#define BBOX_SIZE 100.0f
#define DETECTION_THRESHOLD 0.85f


@implementation ThreeDollarGestureRecognizer
@synthesize resampleAmount;

- (id) initWithResampleAmount:(int) _resampleAmount
{
	self = [super init];
	if (self != nil) {
		self.resampleAmount = _resampleAmount;
	}
	return self;
}

- (Matrix*)prepareMatrixForLibrary: (Matrix*) theTrace{
	
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"RAW MATRIX");
	//[theTrace printMatrix];
	
	gesture_path = [self createPathFromMatrix:theTrace];
	
	NSLog(@"gesture_path Matrix size %d",gesture_path.rows);
	//[gesture_path printMatrix];
	
	resampled_gesture = [self resamplePoints:gesture_path withAmount: self.resampleAmount];	
	
	NSLog(@"resampled_gesture Matrix size %d",resampled_gesture.rows);
	//[resampled_gesture printMatrix];
	
	rotated_gesture = [self rotate_to_zero:resampled_gesture];
	
	NSLog(@"rotated_gesture Matrix size %d",rotated_gesture.rows);
	//[rotated_gesture printMatrix];
	
	Matrix *  normalized_gesture = [self scale_to_cube:rotated_gesture];
	
	NSLog(@"normalized_gesture Matrix size %d",normalized_gesture.rows);
	//[normalized_gesture printMatrix];
	[self reset];
	
	//[pool release];
	
	return normalized_gesture;
}
- (NSString*) recognizeGesture: (Gesture*) candidate fromGestures: (NSDictionary *) library_gestures{
	
	NSString  * recGest = nil;
	
	float pi_half = M_PI/2;
	NSLog(@"vor prepareMatrixForLibrary library_gestures: %d",[library_gestures count]);
	
	Matrix * normalized = [self prepareMatrixForLibrary:candidate.gestureTrace]; 
	candidate.gestureTrace = normalized;
	NSLog(@"after prepareMatrixForLibrary library_gestures: %d",[library_gestures count]);
	
	NSMutableArray * scoreTable = [[NSMutableArray alloc] init];
	
	NSEnumerator *enumerator = [library_gestures objectEnumerator];
	NSArray * gestureList;
	
	float cutoff = 2.0f * (float) M_PI*(15.0f/360.0f);
							 
	
	while ((gestureList = [enumerator nextObject])) {
		NSEnumerator *enumerator = [gestureList objectEnumerator];
		Gesture * gesture;
		int idnr = 0;
		while ((gesture = [enumerator nextObject])) {
						
			float distance = [self distance_at_best_angle_rangeX:pi_half Y: pi_half Z:pi_half increment:0 candidateTrace:candidate.gestureTrace libraryTrace:gesture.gestureTrace andCutOffAngle:cutoff];

			float score =[self score:distance];
			Score * aScore = [[Score alloc] init];
			aScore.distance = distance;
			aScore.gid = gesture.gestureID;
			aScore.score = score;
			aScore.idnr = idnr++;
			[scoreTable addObject:aScore];
		}
		
	}
	NSRange theRange;
	
	theRange.location = 0;
	theRange.length = 3;
	NSArray *scoreTableSorted = [scoreTable  sortedArrayUsingSelector:@selector(compare:)];
	
	Score * s ;
	
	for (int i = [scoreTableSorted count]-1; i >= 0; i--) {
		s = [scoreTableSorted objectAtIndex:i];
		NSLog(@"distance %f score %f for %@ ",s.distance,s.score, s.gid);
	}
	

	recGest = [self recognize_from_scoretable:scoreTableSorted];
	
	return recGest;
}

-(float) distance_at_best_angle_rangeX:(float) angularRangeX Y: (float) angularRangeY Z:(float)angularRangeZ increment: (float) increment
						candidateTrace: (Matrix* ) candidate_points libraryTrace: (Matrix* ) library_points andCutOffAngle: (float) cutoff_angle
{
	
	float mind = MAXFLOAT;
	float maxd = FLT_MIN;//MINFLOAT;
	float minDistAngle = 0.0f;
	float maxDistAngle = 0.0f;

	// end kludge
	
	
	int length1  = candidate_points.rows;
	int length2 = library_points.rows;
	
	
	int sampleLength = 0;
	
	if (length1 < length2)
		sampleLength = length1;
	else
		sampleLength = length2;
	
	length1 = sampleLength;
	length2 = sampleLength;
	
	// todo: print out the lengths
	
	// Golden-Section Search 
	
	float theta_a = -angularRangeX;
	float theta_b = -theta_a;
	float theta_delta = cutoff_angle; // angle at which GSS cuts off
	
	// best angles for lower / upper bound
	
	float bestAngleLower[3] = {0.0f, 0.0f, 0.0f};
	float bestAngleUpper[3] = {0.0f, 0.0f, 0.0f};
	
	// minimum distances
	// initialize lower and upper values to max float
	float minDistL = MAXFLOAT;
	float minDistU = MAXFLOAT;
	
	// golden section
	float phi = 0.5f *(-1.0f+(float) sqrt(5));
	
	// initial lower search angle
	float li = phi*theta_a+(1-phi)*theta_b;
	
	//result of the following function: [[mindist], [a1, a2, a3]]
	Matrix * angle_search_result_lower = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:li bestAngle:bestAngleLower];
	
	
	// assign return values of previous function
	minDistL = angle_search_result_lower.data[0][0];
	bestAngleLower[0] = angle_search_result_lower.data[1][0];
	bestAngleLower[1] = angle_search_result_lower.data[1][1];
	bestAngleLower[2] = angle_search_result_lower.data[1][2];
	
	// initial upper search angle
	float ui = (1-phi)*theta_a+ phi*theta_b;
	//result of the following function: [[mindist], [a1, a2, a3]]
	Matrix * angle_search_result_upper = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:ui bestAngle:bestAngleUpper];
	
	
	// assign return values of previous function
	minDistU = angle_search_result_upper.data[0][0];
	bestAngleUpper[0] = angle_search_result_upper.data[1][0];
	bestAngleUpper[1] = angle_search_result_upper.data[1][1];
	bestAngleUpper[2] = angle_search_result_upper.data[1][2];
	
	while (abs(theta_b-theta_a) > theta_delta) {
		if (minDistL <= minDistU) {
			// continue searching on lower side
			theta_b = ui;
			ui = li;
			minDistU = minDistL;
			li = phi*theta_a+(1-phi)*theta_b;
			//result of the following function: [[mindist], [a1, a2, a3]]
			Matrix * angle_search_result_lower = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:li bestAngle:bestAngleLower];
			// decode result
			minDistL = angle_search_result_lower.data[0][0];
			bestAngleLower[0] = angle_search_result_lower.data[1][0];
			bestAngleLower[1] = angle_search_result_lower.data[1][1];
			bestAngleLower[2] = angle_search_result_lower.data[1][2];

		}
		else {
			theta_a = li;
			li = ui;
			minDistL = minDistU;
			ui = (1-phi)*theta_a + phi*theta_b;
			Matrix * angle_search_result_upper = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:ui bestAngle:bestAngleUpper];
			// decode result
			minDistU = angle_search_result_upper.data[0][0];
			bestAngleUpper[0] = angle_search_result_upper.data[1][0];
			bestAngleUpper[1] = angle_search_result_upper.data[1][1];
			bestAngleUpper[2] = angle_search_result_upper.data[1][2];
		}
		// maybe add angles later
	}
	if (minDistU >= minDistL) 
		return minDistL;
	else 
		return minDistU;
}
-(Matrix*) search_around_angle_candidateTrace: (Matrix* ) candidate libraryTrace: (Matrix* ) template Angle:(float) angle bestAngle: (float*) best_angles{
	float minDist = MAXFLOAT;
	float minAngles[3] = {0.0f, 0.0f, 0.0f};
	
	for (int i = 0; i < 8; i++)
	{
		float  add[3] = {best_angles[0],best_angles[1], best_angles[2]};
		// Greedy Search: go through all combinations (2^3)
		// of adding the angle
		if (i % 2 ==1)
			add[2]+=angle;
		if (i % 4> 1 )
			add[1]+=angle;
		if (i % 8 > 3)
			add[2]+=angle;
		float dist = [self distance_at_angles_candidateTrace:candidate libraryTrace:template andAngles:add];
		if (dist < minDist)
		{
			minDist = dist;
			minAngles[0] = add[0];
			minAngles[1] = add[1];
			minAngles[2] = add[2];
		}
		
	}
//	if (DEBUG) Log.d("Search Around Angle", "minDist "+minDist);
	
	// JAVA float[][] out = new float[][]{{minDist},minAngles};
	Matrix * out =  [[Matrix alloc] initMatrixWithRows:3 andCols:3];
	out.data[0][0] = minDist;
	out.data[1][0] = minAngles[0];
	out.data[1][1] = minAngles[1];
	out.data[1][2] = minAngles[2];
	
	return out;
	
}
- (NSString*) recognize_from_scoretable: (NSArray*) scoreTable{
	/*Implements heuristic for gesture detection:
	 int the top threee, detect at least two candidates of the same gesture id with a score >.55
	 @param scoretable: scoretable sorted by score
	 @return: recognized gesture code or invalid (-100) Gesture*/
	//Log.d("recognize_from_scoretable","Started!");
	int count_h1 = 0;
	int count_h2 = 0;
	// FOR-Schleife ist buggy!
	NSRange theRange;
	
	theRange.location = 0;
	theRange.length = 3;
	
	NSArray * topThreeArray = [scoreTable subarrayWithRange:theRange];
	
	NSEnumerator * enumerator = [topThreeArray objectEnumerator];
	Score * s;
	while((s = [enumerator nextObject]))
	{
		// high-probability match!
		if (s.score > DETECTION_THRESHOLD*1.1)
		{
			NSLog(@"recognize_from_scortable high-probability match!: \t Item: %@ \t score: %f",s.gid,s.score);

			return s.gid;
		}
		// if not high prob, apply heuristic
		// BUG SOMEWHERE HERE!!!!!!
		//ArrayList<Score> scoretable_cpy = (ArrayList<Score>) scoretable.clone();
		//scoretable_cpy.remove(s);
		//scoretable_cpy = (ArrayList<Score>) scoretable_cpy.subList(0, 2);
		if (s.score > DETECTION_THRESHOLD)
		{
			
			NSRange theRange2;
			
			theRange2.location = 1;
			theRange2.length = 2;
			
			NSArray * twoAndThreeArray = [topThreeArray subarrayWithRange:theRange2];
			
			NSEnumerator * enumerator2 = [twoAndThreeArray objectEnumerator];
			Score * other;
			
			
			while((other = [enumerator2 nextObject]))
			{
				NSLog(@"recognize_from_scortable other: \t Item: %@ \t score: %f",other.gid,other.score);

				if ([s.gid isEqualToString:other.gid] && other.score >= DETECTION_THRESHOLD*0.95)
				{
					// heurstic 1
				//	Log.d("recognize_from_scoretable", "h1++");
					NSLog(@"recognize_from_scortable h1++");	
					count_h1++;
					
				}
				if ([s.gid isEqualToString:other.gid])
				{
				//	Log.d("recognize_from_scoretable", "h1++");
					NSLog(@"recognize_from_scortable h2++");	
					count_h2++;
				}
				
				
			} // for
		} // if
		
		// see if heuristic has found likely match
		if (count_h1 >0)
		{
			//Log.i("recognize_from_scoretable", "Decided by H1");
			NSLog(@"recognize_from_scortable Decided by H1");	
			return s.gid;
		}
		else if (count_h2 >1)
		{
			//Log.i("recognize_from_scoretable", "Decided by H2");
			NSLog(@"recognize_from_scortable Decided by H2");	
			return s.gid;
		}
		else
		{
			count_h1 = 0;
			count_h2 = 0;
		}
		
		
		
	} // for (outer)
	// if all else fails, this gesture has not been recognized
	return nil;
}
- (Matrix*)scale_to_cube: (Matrix*) gList{
	/* scale set of points to lie in a cube of standardized size 
	 *  Baustelle! Bearbeitet 18.01.10 --- sollte funzen
	 * */
	Matrix * newpoints = [[Matrix alloc] initMatrixWithRows:gList.rows andCols:3];
	

	Matrix * bbox  = [self bounding_box3:gList];
	NSLog(@"bbox size %d",bbox.rows);
	[bbox printMatrix];
	float bwx = BBOX_SIZE / fabs(bbox.data[0][0] - bbox.data[0][1]);
	float bwy = BBOX_SIZE / fabs(bbox.data[1][0] - bbox.data[1][1]);
	float bwz = BBOX_SIZE / fabs(bbox.data[2][0] - bbox.data[2][1]);
	NSLog(@"bwx %f bwy %f bwz %f",bwx,bwy,bwz);
	
	for (int index = 0;index < gList.rows; index++) {
		
		float * p = gList.data[index];
		
		newpoints.data[index][0] = p[0] * (bwx);
		newpoints.data[index][1] = p[1] * (bwy);
		newpoints.data[index][2] = p[2] * (bwz);
		
	}
	
	return newpoints;
}



- (Matrix*)resamplePoints: (Matrix*) gList withAmount: (int) numSamples{
	
	Matrix * newpoints = [[Matrix alloc] initMatrixWithRows:numSamples andCols:3];
	
	newpoints.data[0][0] = gList.data[0][0] ;
	newpoints.data[0][1] = gList.data[0][1] ;
	newpoints.data[0][2] = gList.data[0][2] ;
	newpoints.rows = 1;
	
	float path_length = [self calculate_path_length:gList];
	float increment = path_length / ((float) numSamples-1);

	float qx,qy,qz; qx = qy = qz = 0.0f;	

	int count = 1;
	
	Matrix * path = [[Matrix alloc] initMatrixWithRows:2 andCols:3];
	path.rows = 2;
	
	float D = 0.0f;
	for (int index = 1;index < gList.rows; index++) {
		
		path.data[0][0] = gList.data[index-1][0];
		path.data[0][1] = gList.data[index-1][1];
		path.data[0][2] = gList.data[index-1][2];
		
		path.data[1][0] = gList.data[index][0];
		path.data[1][1] = gList.data[index][1];
		path.data[1][2] = gList.data[index][2];
		path.rows = 2;
		
		float d  = [self calculate_path_length:path];
		
		if (D + d  >= increment) {
			
			// calculate unit vector from last two vectors in path
			float * v1 = path.data[path.rows-1];
			float * v2 = path.data[path.rows-2];
			
			float missing_incr = (increment - D)/d;
			
			qx = v2[0] + (missing_incr * (v1[0] - v2[0]));
			qy = v2[1] + (missing_incr * (v1[1] - v2[1]));
			qz = v2[2] + (missing_incr * (v1[2] - v2[2]));
			
			
			newpoints.data[newpoints.rows][0] = qx;
			newpoints.data[newpoints.rows][1] = qy;
			newpoints.data[newpoints.rows][2] = qz;
			newpoints.rows++;
			
			//INSERT(points, i, q) // q will be the next pi
			gList.data[index-1][0] = qx;
			gList.data[index-1][1] = qy;
			gList.data[index-1][2] = qz;
			
			D = 0;
			count++;	
			
		}
		else {
			D = D + d;
		}
	
	
	}
	
	return newpoints;
}

- (float) calculate_path_length: (Matrix*) gList{
	
	float distance = 0;
	
	for (int index = 1;index < gList.rows; index++) {
		float * v = gList.data[index];
		float * u = gList.data[index-1];
		float delta = (float) sqrt((u[0]-v[0])*(u[0]-v[0])+(u[1]-v[1])*(u[1]-v[1])+(u[2]-v[2])*(u[2]-v[2]));
		
		distance = distance + delta;
		
	}
	
	return distance;

}
// unused
- (float) distance_sqrt: (float*) u and: (float*) v{ 
	// returns squared distance of vectors u and v
	return (float) sqrt((u[0]-v[0])*(u[0]-v[0])+(u[1]-v[1])*(u[1]-v[1])+(u[2]-v[2])*(u[2]-v[2]));
}

- (float*) orthogonal: (float*) b and: (float*) c{ 
	// returns vector orthogonal to (cross-product of) b and c
	// a = b x c, mnemonic: xyzzy
	float ax,ay,az;
	ax = b[1]*c[2] - b[2]*c[1]; //ByCz - BzCy
	ay = b[2]*c[0] - b[0]*c[2]; //BzCx - BxCz
	az = b[0]*c[1] - b[1]*c[0]; //BxCy - ByCx
	
	Matrix * out = [[[Matrix alloc] initMatrixWithRows:1 andCols:3] autorelease];
	out.data[0][0] = ax;
	out.data[0][1] = ay;
	out.data[0][2] = az;
	
	return out.data[0];

}

- (float *) unit_vector: (float*) v{
	// returns a unit vector with direction given by v
	Matrix * zero = [Matrix zeroVec3]; 
	float norm = 1.0f / sqrt((v[0]-zero.data[0][0])*(v[0]-zero.data[0][0])+(v[1]-zero.data[0][1])*(v[1]-zero.data[0][1])+(v[2]-zero.data[0][2])*(v[2]-zero.data[0][2]));
	Matrix * out = [[[Matrix alloc] initMatrixWithRows:1 andCols:3] autorelease];
	out.data[0][0] = norm*v[0];
	out.data[0][1] = norm*v[1];
	out.data[0][2] = norm*v[2];
	return out.data[0];
}

- (Matrix*)rotate_to_zero: (Matrix*) gList{
	Matrix * rotated_points = [[[Matrix alloc] initMatrixWithRows:gList.rows andCols:3] autorelease];
	Matrix *  centroidMatrix=[self centroidFromTrace:gList];
	
	float * centroid = centroidMatrix.data[0];
	float theta = [self angle3:centroid andV:gList.data[0]];
	//float[] axis = this.unit_vector(this.orthogonal(points.get(0), centroid));
	float * axis = [self unit_vector: [self orthogonal:gList.data[0] and:centroid]];
	
	Matrix * r_matrix  = [self rotationMatrixWithVector3:axis andTheta:theta];
	
	
	for (int i = 0; i < gList.rows; i++) {
		
		float * p = gList.data[i];
		
		Matrix * temp =  [self rotate3: p withMatrix: r_matrix];
		rotated_points.data[i][0] = temp.data[0][0];
		rotated_points.data[i][1] = temp.data[0][1];
		rotated_points.data[i][2] = temp.data[0][2];
		
	}
	return rotated_points;
}
- (Matrix*) rotate3: (float *) p withMatrix:(Matrix*) matrix{
	// multiply 3x3 rotation matrix with point (no list comprehension here)
	
	Matrix * out = [[[Matrix alloc] initMatrixWithRows:1 andCols:3] autorelease];
	
	for (int i = 0; i < 3; i++)
	{
		float * r = matrix.data[i];
		out.data[0][i] = p[0]*r[0] + p[1]*r[1]+ p[2]*r[2];
	}
	
	return out;

}
- (Matrix*) rotationMatrixWithAngle3Alpha: (float) a Beta: (float) b Gamma: (float) g{
	// returns three-angle rotation matrix
	Matrix * rotMatrix = [[[Matrix alloc] initMatrixWithRows:3 andCols:3] autorelease]; 
	
	rotMatrix.data[0][0] = (float) (cos(a)*cos(b));
	rotMatrix.data[0][1] = (float)(cos(a)*sin(b)*sin(g)-sin(a)*cos(g)) ;
	rotMatrix.data[0][2] =  (float)(cos(a)*sin(b)*cos(g)+sin(a)*sin(g));

	rotMatrix.data[1][0] = (float)(sin(a)*cos(b));
	rotMatrix.data[1][1] = (float)(sin(a)*sin(b)*sin(g)+cos(a)*cos(g));
	rotMatrix.data[1][2] =   (float)(sin(a)*sin(b)*cos(g) - cos(a)*sin(g));

	rotMatrix.data[2][0] = (float)(-sin(b));
	rotMatrix.data[2][1] = (float)(cos(b)*sin(g));
	rotMatrix.data[2][2] = (float)(cos(b)*cos(g));

	return rotMatrix;

}

- (Matrix*) rotationMatrixWithVector3: (float *) axis andTheta:(float) theta{
	// generate a rotation matrix for rotation along axis with the value theta
	
	Matrix * matrix = [[[Matrix alloc] initMatrixWithRows:3 andCols:3] autorelease];
	
	float x = axis[0];
	float y = axis[1];
	float z = axis[2];
	int k;
	float angle = (float) theta;
	
	
	matrix.data[0][0] = (float) (1 + (1-cos(angle))*(x*x-1));
	matrix.data[0][1] = (float) ((float) -z*sin(angle)+(1-cos(angle))*x*y);
	matrix.data[0][2] = (float) (y*sin(angle)+(1-cos(angle))*x*z);
	
	
	matrix.data[1][0] = (float)(z*sin(angle)+(1-cos(angle))*x*y);
	matrix.data[1][1] = (float) (1 + (1-cos(angle))*(y*y-1));
	matrix.data[1][2] = (float) (-x*sin(angle)+(1-cos(angle))*y*z);
	
	matrix.data[2][0] = (float) (-y*sin(angle)+(1-cos(angle))*x*z);
	matrix.data[2][1] = (float) (x*sin(angle)+(1-cos(angle))*y*z);
	matrix.data[2][2] = (float) (float) (1 + (1-cos(angle))*(z*z-1));

	return matrix;
}
- (float) angle3: (float *) u andV:(float *) v{
	float norm_product = [self norm_dot_product:u andV: v];
	if (norm_product <= 1.0f)
	{
		float theta = (float) acos(norm_product);
		return theta;
	}
	else
	{
		return 0.0f;
	}

} 
- (float) norm_dot_product: (float *) u andV:(float *) v{
	// return normalized dot product (for angle calculation)
	
	float a = [self dot_product3:u andV:v];
	float b = [self norm:u] * [self norm:v];
	return a/b;	
} 

- (float) norm: (float *) u{
	return (float) sqrt(u[0]*u[0]+u[1]*u[1]+u[2]*u[2]);
}
- (float) dot_product3:  (float *) u andV:(float *) v{
	return u[0]*v[0]+u[1]*v[1]+u[2]*v[2];
}

- (Matrix*)centroidFromTrace: (Matrix*) gList{
	
	// calculates centorid of point list
	float mx = 0.0f;
	float my = 0.0f;
	float mz = 0.0f;
	
	
	for (int i = 0; i < gList.rows; i++) {
	
		float * p = gList.data[i];
		mx += p[0];
		my += p[1];
		mz += p[2];
		
		
	}
	// length of points
	int l = gList.rows;
	Matrix * ret = [[[Matrix alloc] initMatrixWithRows:1 andCols:3] autorelease];
	
		ret.data[0][0] = mx/l;
		ret.data[0][1] = my/l;
		ret.data[0][2] = mz/l;
	
	return ret;
	
}

- (Matrix*)createPathFromMatrix: (Matrix*) gList{
	Matrix * path = [[Matrix alloc] initMatrixWithRows:gList.rows andCols:3];
	
	path.data[0][0] = gList.data[0][0];
	path.data[0][1] = gList.data[0][1];
	path.data[0][2] = gList.data[0][2];

	
	for (int i = 1; i < gList.rows; i++) {
		path.data[i][0] = gList.data[i][0]+path.data[i][0];
		path.data[i][1] = gList.data[i][1]+path.data[i][1];
		path.data[i][2] = gList.data[i][2]+path.data[i][2];
	}
	
	return path;
}

-(float) score: (float) distance{
	/*
	 * Scoring heuristic, derived from Wobbrock paper.
	 */	
	float b = BBOX_SIZE;
	return 1.0f - (distance / ((float)sqrt(b*b+b*b+b*b)));
}

- (Matrix *) bounding_box3: (Matrix *) points
{
	/* returns bounding box in 3d space of set of points */
	Matrix * outMatrix = [[[Matrix alloc] initMatrixWithRows:3 andCols:2] autorelease];
	
	

	float * p;
	// sanity check
	if (points.rows > 0) 
	{
		p = points.data[points.rows-1];
	}
	else 
	{
		return outMatrix;
	}
	
	float mmx[2] = { p[0], p[0]};
	float mmy[2] = { p[1], p[1]};
	float mmz[2]= { p[2], p[2]};
	
	// iterate over points to determine boundaries
	for (int i = 1; i < points.rows; i++) {
		
		float * p = points.data[i];
		
		if (p[0] <= mmx[0])
		{
			mmx[0] = p[0];
		}       
		else if (p[0] > mmx[1])
		{
			mmx[1] = p[0];
		}
		
		if (p[1] <= mmy[0])
		{
			mmy[0] = p[1];
		}            
		else if (p[1] > mmy[1])
		{
			mmy[1] = p[1];
		}
		
		if (p[2] <= mmz[0])
		{
			mmz[0] = p[2];
		}         
		else if (p[2] > mmz[1])
		{
			mmz[1] = p[2];
		}	
	}
	
	outMatrix.data[0][0] = mmx[0];
	outMatrix.data[0][1] = mmx[1];
	outMatrix.data[1][0] = mmy[0];
	outMatrix.data[1][1] = mmy[1];
	outMatrix.data[2][0] = mmz[0];
	outMatrix.data[2][1] = mmz[1];
	
	return outMatrix;
	
}

-(float) distance_at_angles_candidateTrace: (Matrix* ) candidate libraryTrace: (Matrix* ) template andAngles: (float*) angles{
	
	float dist = MAXFLOAT;
	
	// Being implemented 18.01.09
	
	float alpha = angles[0];
	float beta = angles[1];
	float gamma = angles[2];
	
	Matrix * matrix = [self rotationMatrixWithAngle3Alpha:alpha Beta:beta Gamma:gamma];
	// rotate path according to angles and calculate distance
	Matrix * newCandPoints = [[[Matrix alloc] initMatrixWithRows:candidate.rows andCols:3] autorelease];

	for (int i = 0; i < candidate.rows; i++) {
		Matrix * np = [self rotate3:candidate.data[i] withMatrix:matrix];
		
		newCandPoints.data[i][0] = np.data[0][0];
		newCandPoints.data[i][1] = np.data[0][1];
		newCandPoints.data[i][2] = np.data[0][2];
	}
	
	// save length because they get manuplated in path_distance_candidateTrace
	
	int candidateRows = candidate.rows;
	int templateRows = template.rows;
	
	dist = [self path_distance_candidateTrace:candidate libraryTrace:template];
	
	candidate.rows = candidateRows;
	template.rows = templateRows;
	
	return dist;
}
-(float) path_distance_candidateTrace: (Matrix* ) path1 libraryTrace: (Matrix* ) path2{
	
	int length1 = path1.rows;
	int length2 = path2.rows;
	
	float distance = 0.0f;
	int idx = 0;
	
	if (length1 == length2)
	{
		for (int i = 0; i < length1; i++)
		{
			float * v1 = path1.data[i];
			float * v2 = path2.data[i];
			distance += [self distance_sqrt:v1 and:v2];
			return distance; // / length1;
		}
	}
	else
	{
		//if (VERBOSE) Log.d("path_distances", "distances not equal, trimming");
		if (length1 < length2)
		{
			int diff = length2-length1;
			// trim items
			
			for (int i = length1-1; i < diff+length1-1; i++)
			{
				// remove tail object
				//p2.remove(p2.size()-1);
				path2.rows = path2.rows-1;
			}
			// recurse 
			return [self path_distance_candidateTrace:path1 libraryTrace:path2];
		}
		else
		{
			int diff = length1 - length2;
			
			for (int i = length2-1; i < diff+length2-1; i++)
			{
				// remove tail object
				//p1.remove(p1.size()-1);
				path1.rows = path1.rows-1;
			}
			//recurse
			return [self path_distance_candidateTrace:path1 libraryTrace:path2];
		}
	}
	return distance;
}
-(void) reset{
	
	
	//[gesture_path dealloc];
	//[resampled_gesture dealloc];
	//[rotated_gesture dealloc];
}
@end
