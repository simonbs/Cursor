//
//  Matrix.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 25.01.10.
//

#import <Foundation/Foundation.h>


@interface Matrix : NSObject {	
	uint rows,cols;
	float** data;
}
@property (nonatomic, assign) uint rows;
@property (nonatomic, assign) uint cols;
@property (nonatomic, assign) float** data;

- (void) printVector: (float*) vec withSize: (uint) size;
- (void) printMatrix;
- (void) emptyMatrix;
- (void) copy: (float*) source Into: (float*) target andSize:(uint) size;
- (Matrix*) initMatrixWithRows:(uint) _rows andCols:(uint) _cols;

+ (Matrix*) zeroVec3;

@end
