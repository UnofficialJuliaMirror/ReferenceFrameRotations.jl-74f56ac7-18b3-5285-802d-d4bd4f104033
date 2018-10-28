################################################################################
#                          TEST: DCM <=> Euler Angles
################################################################################

for k = 1:samples
    for rot_seq in rot_seq_array
        # Sample three angles form a uniform distribution [-pi,pi].
        θx = -pi + 2*pi*rand()
        θy = -pi + 2*pi*rand()
        θz = -pi + 2*pi*rand()
        Θ  = EulerAngles(θx, θy, θz, rot_seq)

        # Get the error matrix related to the conversion from DCM => Euler
        # Angles => DCM.
        error1 = angle_to_rot(DCM, dcm_to_angle(angle_to_rot(Θ),rot_seq)) -
                 angle_to_rot(DCM, θx, θy, θz, rot_seq)
        error2 = angle_to_rot(dcm_to_angle(angle_to_rot(θx, θy, θz, rot_seq),rot_seq)) -
                 angle_to_rot(Θ)

        # If everything is fine, the norm of the matrix error should be small.
        @test norm(error1) < 1e-10
        @test norm(error2) < 1e-10
        @test error1 ≈ error2
    end
end

for k = 1:samples
    # Sample three angles form a uniform distribution [-0.0001,0.0001].
    θx = -0.0001 + 0.0002*pi*rand()
    θy = -0.0001 + 0.0002*pi*rand()
    θz = -0.0001 + 0.0002*pi*rand()
    Θ  = EulerAngles(θx, θy, θz, :XYZ)

    # Get the error between the exact rotation and the small angle
    # approximation.
    error1 = angle_to_rot(Θ) - smallangle_to_rot(DCM, Θ.a1, Θ.a2, Θ.a3)
    error2 = angle_to_rot(θx, θy, θz, :XYZ) - smallangle_to_rot(Θ.a1, Θ.a2, Θ.a3)

    # If everything is fine, the norm of the matrix error should be small.
    #
    # TODO: 2018-06-21: Some tests were failing with the tolerance `5e-7` in
    # nightly builds in Windows. Those failures were not seen in Linux or macOS.
    @test norm(error1) < 7e-7
    @test norm(error2) < 7e-7
    @test error1 ≈ error2
end

# Test exceptions.
@test_throws ArgumentError angle_to_dcm(0,0,0,:xyz)
@test_throws ArgumentError angle_to_dcm(0,0,0,:zyx)
@test_throws ArgumentError angle_to_dcm(0,0,0,:xyx)
@test_throws ArgumentError angle_to_dcm(0,0,0,:abc)
@test_throws ArgumentError angle_to_quat(0,0,0,:xyz)
@test_throws ArgumentError angle_to_quat(0,0,0,:zyx)
@test_throws ArgumentError angle_to_quat(0,0,0,:xyx)
@test_throws ArgumentError angle_to_quat(0,0,0,:abc)
